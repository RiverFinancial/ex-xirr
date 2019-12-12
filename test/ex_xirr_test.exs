defmodule ExXirrTest do
  use ExUnit.Case, async: true
  doctest ExXirr

  describe "xirr/2" do
    test "positive and negative flow in the same day" do
      assert ExXirr.xirr([
               {{2014, 04, 15}, -10000.0},
               {{2014, 04, 15}, 10000.0},
               {{2014, 10, 19}, 500.0}
             ]) ==
               {:error, "Values should have at least one positive or negative value."}
    end

    test "impossible returns on investments" do
      assert ExXirr.xirr([
               {{2015, 11, 1}, -800_000},
               {{2015, 10, 1}, -2_200_000},
               {{2015, 6, 1}, 1_000_000}
             ]) == {:ok, 21.118359}
    end

    test "bad investment" do
      assert ExXirr.xirr([{{1985, 1, 1}, 1000}, {{1990, 1, 1}, -600}, {{1995, 1, 1}, -200}]) ==
               {:ok, -0.034592}
    end

    test "repeated cashflow" do
      v = [1000.0, 2000.0, -2000.0, -4000.0]
      d = [{2011, 12, 07}, {2011, 12, 07}, {2013, 05, 21}, {2013, 05, 21}]

      assert ExXirr.xirr(Enum.zip(d, v)) == {:ok, 0.610359}
    end

    test "ok investment" do
      assert ExXirr.xirr([{{1985, 1, 1}, 1000}, {{1990, 1, 1}, -600.0}, {{1995, 1, 1}, -6000.0}]) ==
               {:ok, 0.225683}
    end

    test "long investment" do
      v = [
        105_187.06,
        -816_709.66,
        479_069.684,
        937_309.708,
        88622.661,
        100_000.0,
        80000.0,
        403_627.95,
        508_117.9,
        789_706.87,
        -88622.661,
        -789_706.871,
        -688_117.9,
        -403_627.95,
        403_627.95,
        789_706.871,
        88622.661,
        688_117.9,
        45129.14,
        26472.08,
        51793.2,
        126_605.59,
        278_532.29,
        99284.1,
        58238.57,
        113_945.03,
        405_137.88,
        -405_137.88,
        165_738.23,
        -165_738.23,
        144_413.24,
        84710.65,
        -84710.65,
        -144_413.24
      ]

      d = [
        {2011, 12, 07},
        {2011, 12, 07},
        {2011, 12, 07},
        {2012, 01, 18},
        {2012, 07, 03},
        {2012, 07, 03},
        {2012, 07, 19},
        {2012, 07, 23},
        {2012, 07, 23},
        {2012, 07, 23},
        {2012, 09, 11},
        {2012, 09, 11},
        {2012, 09, 11},
        {2012, 09, 11},
        {2012, 09, 12},
        {2012, 09, 12},
        {2012, 09, 12},
        {2012, 09, 12},
        {2013, 03, 11},
        {2013, 03, 11},
        {2013, 03, 11},
        {2013, 03, 11},
        {2013, 03, 28},
        {2013, 03, 28},
        {2013, 03, 28},
        {2013, 03, 28},
        {2013, 05, 21},
        {2013, 05, 21},
        {2013, 05, 21},
        {2013, 05, 21},
        {2013, 05, 21},
        {2013, 05, 21},
        {2013, 05, 21},
        {2013, 05, 21}
      ]

      assert ExXirr.xirr(Enum.zip(d, v)) == {:ok, 190_338.715931}
    end

    test "wrong values" do
      d = [
        {2014, 04, 15},
        {2014, 10, 19}
      ]

      v = [
        305.6,
        500.0
      ]

      assert ExXirr.xirr(Enum.zip(d, v)) ==
               {:error, "Values should have at least one positive or negative value."}
    end

    test "not a bad investment" do
      d = [{2008, 2, 5}, {2008, 7, 5}, {2009, 1, 5}]
      v = [2750.0, -1000.0, -2000.0]

      assert ExXirr.xirr(Enum.zip(d, v)) == {:ok, 0.123631}
    end

    test "fail when the rate is too large" do
      d = [{2017, 1, 1}, {2017, 1, 5}]
      v = [10000, -11000]
      assert ExXirr.xirr(Enum.zip(d, v)) == {:error, "Unable to converge"}
    end

    test "zero cash flow should not affect xirr result" do
      v = [
        2_048_092,
        -100_000,
        -100_000,
        -100_000,
        -100_000,
        -100_000,
        -100_000,
        -100_000,
        -50000,
        -10000
      ]

      d = [
        {2019, 11, 12},
        {2019, 10, 15},
        {2019, 9, 15},
        {2019, 8, 15},
        {2018, 10, 1},
        {2018, 2, 21},
        {2017, 12, 24},
        {2017, 9, 17},
        {2016, 2, 21},
        {2016, 2, 20}
      ]

      {:ok, result_without_zero_cash_flow} = ExXirr.xirr(Enum.zip(d, v))

      v_with_zero_cash_flows = [
        2_048_092,
        0,
        -100_000,
        -100_000,
        -100_000,
        -100_000,
        -100_000,
        -100_000,
        -100_000,
        -50000,
        -10000
      ]

      d_with_zero_cash_flows = [
        {2019, 11, 12},
        {2018, 11, 12},
        {2019, 10, 15},
        {2019, 9, 15},
        {2019, 8, 15},
        {2018, 10, 1},
        {2018, 2, 21},
        {2017, 12, 24},
        {2017, 9, 17},
        {2016, 2, 21},
        {2016, 2, 20}
      ]

      {:ok, result_with_zero_cash_flows} =
        ExXirr.xirr(Enum.zip(d_with_zero_cash_flows, v_with_zero_cash_flows))

      assert result_without_zero_cash_flow == result_with_zero_cash_flows
    end
  end
end
