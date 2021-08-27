defmodule QcxControl.Spec do
  use ESpec

  specify "test" do
    QcxControl.hello() |> should(eq :world)
  end
end
