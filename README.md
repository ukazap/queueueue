# Queueueue

Elixir wrapper for Erlang's [`queue`](https://www.erlang.org/doc/man/queue.html) with optional `max_length` and O(1) `.length` query.

## Installation

The package can be installed by adding `queueueue` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:queueueue, github: "ukazap/queueueue", tag: "v0.1.0"}
  ]
end
```

## Usage

```elixir
alias Queueueue, as: Queue # if you wish

# Create new queue with optional max length set to 5 (default is ∞)
q = Queue.new(5)

0 = Queue.length(q)

q = 
  q
  |> Queue.enqueue("Yudhishthira")
  |> Queue.enqueue("Bhima")
  |> Queue.enqueue("Arjuna")
  |> Queue.enqueue("Nakula")
  |> Queue.enqueue("Sahadeva")

5 = Queue.length(q)

{:error, :queue_full} = q |> Queue.enqueue("Duryodhana")

{{:value, "Yudhishthira"}, q} = Queue.dequeue(q)
{{:value, "Bhima"}, q} = Queue.dequeue(q)

3 = Queue.length(q)

# Queueueue implements Enumerable protocol
3 = Enum.count(q)
["Hello, Arjuna", "Hello, Nakula", "Hello, Sahadeva"] = Enum.map(q, &"Hello, #{&1}")
```
