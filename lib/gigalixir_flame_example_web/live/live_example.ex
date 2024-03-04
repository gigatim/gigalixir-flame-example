defmodule GigalixirFlameExampleWeb.LiveExample do
  use GigalixirFlameExampleWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0, results: []), temporary_assigns: [node: Node.self()]}
  end

  def render(assigns) do
    ~H"""
    <h1>Live Example</h1>
    <p>Node: <%= @node %></p>
    <p>Running: <%= @count != 0 %></p>
    <button class="bg-blue-500 p-2" phx-click="run_job">Run</button>
    <ul class="mt-4 px-4" :for={result <- @results}>
      <li :for={subresult <- result}><%= subresult %></li>
    </ul>
    """
  end

  def handle_event("run_job", _params, socket) do
    IO.puts("Starting job")
    requester = Node.self()

    send(self(), {:do_job, requester})

    count = socket.assigns.count + 1

    {:noreply, assign(socket, count: count)}
  end

  def handle_info({:do_job, requester}, socket) do
    {:ok, processor, from_flame} = process_job()

    IO.puts("Job completed")

    new_result = [
      "completed: #{Time.to_string(Time.utc_now())}",
      "requester: #{requester}", 
      "processor: #{processor} #{from_flame && "(FLAME)" || "(not FLAME)"}",
      "finisher: #{Node.self()}",
    ]
    previous_results = socket.assigns.results
    count = socket.assigns.count - 1

    {:noreply, assign(socket, count: count, results: [new_result | previous_results])}
  end

  defp process_job() do
    FLAME.call(GigalixirFlameExample.FlameWorker, fn ->
      IO.puts("Running Job")

      # faking the work effort
      Process.sleep(2_000)

      IO.puts("Job done")

      {:ok, Node.self(), FLAME.Parent.get() != nil}
    end)
  end
end
