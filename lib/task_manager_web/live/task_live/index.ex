defmodule TaskManagerWeb.TaskLive.Index do
  use TaskManagerWeb, :live_view

  alias TaskManager.Tasks
  alias TaskManager.Tasks.Task

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Tasks.subscribe()

    {:ok, stream(socket, :tasks, Tasks.list_tasks()), temporary_assigns: [tasks: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:task, Tasks.get_task!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Task")
    |> assign(:task, %Task{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tasks")
    |> assign(:task, nil)
  end

  @impl true
  def handle_info({TaskManagerWeb.TaskLive.FormComponent, {:saved, task}}, socket) do
    {:noreply, update(socket, :tasks, fn tasks -> [task | tasks] end)}
  end

  def handle_info({TaskManagerWeb.TaskLive.FormComponent, {:updated, task}}, socket) do
    {:noreply, update(socket, :tasks, fn tasks -> [task | tasks] end)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply, stream_delete(socket, :tasks, task)}
  end
end
