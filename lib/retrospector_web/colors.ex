defmodule RetrospectorWeb.Colors do
  @names ["sky", "amber", "teal", "green", "indigo", "pink", "lime", "red"]

  @classes %{
    "sky" => "bg-sky-800",
    "amber" => "bg-amber-800",
    "teal" => "bg-teal-800",
    "green" => "bg-green-800",
    "indigo" => "bg-indigo-800",
    "pink" => "bg-pink-800",
    "lime" => "bg-lime-800",
    "red" => "bg-red-800",
    "gray" => "bg-gray-800"
  }
  def getColorClass(color) do
    @classes[color]
  end

  def getColorForIndex(index) do
    Enum.at(@names, index, "gray")
  end
end
