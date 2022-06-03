defmodule RetrospectorWeb.Colors do
  @names ["sky", "amber", "teal"]

  @classes %{
    "sky" => "bg-sky-800",
    "amber" => "bg-amber-800",
    "teal" => "bg-teal-800",
    "gray" => "bg-gray-800"
  }
  def getColorClass(color) do
    @classes[color]
  end

  def getColorForIndex(index) do
    Enum.at(@names, index, "gray")
  end
end
