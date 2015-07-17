defmodule Output.DocTest do
  use ExUnit.Case, async: true

  defmodule SomeSpec do
    use ESpec

    it do: expect(1).to eq(1)
    it do: expect(1).to eq(2)
    xit do: expect(1).to eq(1)
  end

  setup_all do
    examples = ESpec.Runner.run_examples(SomeSpec.examples)
    {:ok,
      examples: examples,
      success_example: Enum.at(examples, 0),
      failed_example: Enum.at(examples, 1),
      pending_example: Enum.at(examples, 2)
    }
  end

  test "format_example success_example", context do
    output = ESpec.Output.Doc.format_example(context[:success_example], %{})
    assert output == "\e[32m.\e[0m"
    output = ESpec.Output.Doc.format_example(context[:success_example], %{details: true})
    assert output == "Output.DocTest.SomeSpec\n  \e[32m\"`1` equals `1`.\"\e[0m\n"
  end

  test "format_example failed_example", context do
    output = ESpec.Output.Doc.format_example(context[:failed_example], %{})
    assert output == "\e[31mF\e[0m"
    output = ESpec.Output.Doc.format_example(context[:failed_example], %{details: true})
    assert output == "Output.DocTest.SomeSpec\n  \e[31mExpected `1` to equals (==) `2`, but it doesn't.\e[0m\n"
  end

  test "format_example pending_example", context do
    output = ESpec.Output.Doc.format_example(context[:pending_example], %{})
    assert output == "\e[33m*\e[0m"
    output = ESpec.Output.Doc.format_example(context[:pending_example], %{details: true})
    assert output == "Output.DocTest.SomeSpec\n  \e[33m\"Temporarily skipped with: `xit`.\"\e[0m\n"
  end

  test "format_result", context do
    times = {{1436, 865768, 500000}, {1436, 865768, 500100}, {1436, 865768, 500200}}
    output = ESpec.Output.Doc.format_result(context[:examples], times, %{})
    assert String.match?(output, ~r/Output\.DocTest\.SomeSpec/)
    assert String.match?(output, ~r/Temporarily skipped with: `xit`/)
    assert String.match?(output, ~r/Expected `1` to equals/)
    assert String.match?(output, ~r/3 examples, 1 failures, 1 pending/)
  end
end