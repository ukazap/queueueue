defmodule QueueueueTest do
  use ExUnit.Case

  describe ".new/0" do
    test "creates an unbounded queue" do
      assert %Queueueue{max_length: :infinity} = Queueueue.new()
    end
  end

  describe ".new/1" do
    test "creates a bounded queue" do
      assert %Queueueue{max_length: 10_000} = Queueueue.new(10_000)
    end
  end

  describe ".enqueue/2" do
    test "puts new item on queue" do
      for item <- 1..10_000_000, reduce: Queueueue.new() do
        queue ->
          assert %Queueueue{length: ^item} = queue = Queueueue.enqueue(queue, item)
          queue
      end
    end

    test "rejects new item if full" do
      queue = Queueueue.new(3)
      assert %Queueueue{length: 1} = queue = Queueueue.enqueue(queue, "一")
      assert %Queueueue{length: 2} = queue = Queueueue.enqueue(queue, "二")
      assert %Queueueue{length: 3} = queue = Queueueue.enqueue(queue, "三")
      assert {:error, :queue_full} = Queueueue.enqueue(queue, "四")
    end
  end

  describe ".dequeue/1" do
    test "takes the front-most item out of the queue and returns smaller queue" do
      queue = Queueueue.new()
      queue = Queueueue.enqueue(queue, "Huey")
      queue = Queueueue.enqueue(queue, "Dewey")
      queue = Queueueue.enqueue(queue, "Lewey")

      assert {{:value, "Huey"}, %Queueueue{length: 2} = queue} = Queueueue.dequeue(queue)
      assert {{:value, "Dewey"}, %Queueueue{length: 1} = queue} = Queueueue.dequeue(queue)
      assert {{:value, "Lewey"}, %Queueueue{length: 0} = queue} = Queueueue.dequeue(queue)
      assert {:empty, %Queueueue{length: 0}} = Queueueue.dequeue(queue)
    end
  end

  describe ".length/1" do
    test "returns queue length without traversing the queue" do
      queue1 =
        for item <- 1..5, reduce: Queueueue.new() do
          queue -> Queueueue.enqueue(queue, item)
        end

      queue2 =
        for item <- 1..5_000_000, reduce: Queueueue.new() do
          queue -> Queueueue.enqueue(queue, item)
        end

      assert {time1, 5} = :timer.tc(fn -> Queueueue.length(queue1) end)
      assert {time2, 5_000_000} = :timer.tc(fn -> Queueueue.length(queue2) end)

      time1 = max(time1, 1)
      time2 = max(time2, 1)

      assert abs(time1 - time2) < min(time1, time2) * 2
    end
  end
end
