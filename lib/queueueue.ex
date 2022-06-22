defmodule Queueueue do
  @moduledoc """
  Elixir wrapper for Erlang's :queue with optional `max_length` and O(1) `.length` query.
  """

  @type t :: %__MODULE__{
          q: {list(), list()},
          length: pos_integer(),
          max_length: pos_integer() | :infinity
        }

  @derive {Inspect, only: [:max_length, :length]}

  defstruct max_length: :infinity, q: :queue.new(), length: 0

  @spec new :: t()
  @spec new(pos_integer()) :: t()
  def new(), do: struct(__MODULE__)
  def new(size) when size > 0, do: struct(__MODULE__, max_length: size)

  @spec enqueue(t(), any()) :: t() | {:error, :queue_full}
  def enqueue(%__MODULE__{length: length, max_length: max_length}, _)
      when max_length != :infinity and length >= max_length do
    {:error, :queue_full}
  end

  def enqueue(%__MODULE__{q: q, length: length} = queue, item) do
    %{
      queue
      | q: :queue.in(item, q),
        length: length + 1
    }
  end

  @spec dequeue(t()) :: {:empty | {:value, any()}, t()}
  def dequeue(%__MODULE__{q: q, length: length} = queue) do
    {out, q} = :queue.out(q)
    {out, %{queue | q: q, length: max(length - 1, 0)}}
  end

  @spec length(t()) :: pos_integer()
  def length(%__MODULE__{length: length}), do: length

  @spec to_list(t()) :: list()
  def to_list(%__MODULE__{q: q}), do: :queue.to_list(q)

  defimpl Enumerable do
    def count(queue) do
      {:ok, Queueueue.length(queue)}
    end

    def member?(queue, value) do
      {:ok, Enum.member?(Queueueue.to_list(queue), value)}
    end

    def slice(queue) do
      length = Queueueue.length(queue)
      {:ok, length, &Enumerable.List.slice(Queueueue.to_list(queue), &1, &2, length)}
    end

    def reduce(queue, acc, fun) do
      Enumerable.List.reduce(Queueueue.to_list(queue), acc, fun)
    end
  end
end
