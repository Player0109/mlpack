# @file runtests.jl
# @author Ryan Curtin
#
# Tests for the Julia bindings.
include("/home/ryan/src/mlpack-rc2/build/src/mlpack/bindings/julia/mlpack/test_julia_binding.jl")
using Test
#using mlpack

# The return order for the binding is this:
#
# col_out, double_out, int_out, matrix_and_info_out, matrix_out, model_bw_out,
# model_out, row_out, str_vector_out, string_out, ucol_out, umatrix_out,
# urow_out, vector_out
#
# That's a lot of parameters!  But this is an atypical binding...

# Test that when we run the binding correctly (with correct input parameters),
# we get the expected output.
@testset "TestRunBindingCorrectly" begin
  _, dblOut, intOut, _, _, _, _, _, _, strOut, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         flag1=true)

  @test strOut == "hello2"
  @test intOut == 13
  @test dblOut == 5.0
end

# If we forget the mandatory flag, we should get wrong results.
@testset "TestRunBindingNoFlag" begin
  _, dblOut, intOut, _, _, _, _, _, _, strOut, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello")

  @test strOut != "hello2"
  @test intOut != 13
  @test dblOut != 5.0
end

# If we give the wrong string, we should get wrong results.
@testset "TestRunBindingWrongString" begin
  _, _, _, _, _, _, _, _, _, strOut, _, _, _, _ =
      test_julia_binding(4.0, 12, "goodbye",
                         flag1=true)

  @test strOut != "hello2"
end

# If we give the wrong int, we should get wrong results.
@testset "TestRunBindingWrongInt" begin
  _, _, intOut, _, _, _, _, _, _, _, _, _, _, _ =
      test_julia_binding(4.0, 15, "hello",
                         flag1=true)

  @test intOut != 13
end

# If we give the wrong double, we should get wrong results.
@testset "TestRunBindingWrongDouble" begin
  _, dblOut, _, _, _, _, _, _, _, _, _, _, _, _ =
      test_julia_binding(2.0, 12, "hello",
                         flag1=true)

  @test dblOut != 5.0
end

# If we give the second flag, this should fail.
@testset "TestRunBadFlag" begin
  _, dblOut, intOut, _, _, _, _, _, _, strOut, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         flag1=true,
                         flag2=true)

  @test strOut != "hello2"
  @test intOut != 13
  @test dblOut != 5.0
end

# The matrix we pass in, we should get back with the third dimension doubled and
# the fifth forgotten.
@testset "TestMatrix" begin
  x = rand(100, 5)

  _, _, _, _, matOut, _, _, _, _, _, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         matrix_in=x,
                         points_are_rows=true)

  @test size(matOut, 1) == 100
  @test size(matOut, 2) == 4
  @test typeof(matOut[1, 1]) == Float64
  for i in [0, 1, 3]
    for j in 1:100
      @test matOut[j, i + 1] == x[j, i + 1]
    end
  end

  for j in 1:100
    @test matOut[j, 3] == 2 * x[j, 3]
  end
end

# The matrix we pass in, we should get back with the third dimension doubled and
# the fifth forgotten.  This test is column major.
@testset "TestMatrixColMajor" begin
  x = rand(5, 100)

  _, _, _, _, matOut, _, _, _, _, _, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         matrix_in=x)

  @test size(matOut, 1) == 4
  @test size(matOut, 2) == 100
  @test typeof(matOut[1, 1]) == Float64
  for i in 1:100
    for j in [0, 1, 3]
      @test matOut[j + 1, i] == x[j + 1, i]
    end
  end

  for j in 1:100
    @test matOut[3, j] == 2 * x[3, j]
  end
end

# Same as TestMatrix but with an unsigned matrix.
@testset "TestUMatrix" begin
  # Generate a random matrix of integers.
  x = convert(Array{UInt64, 2}, rand(1:500, (100, 5)))

  _, _, _, _, _, _, _, _, _, _, _, umatOut, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         umatrix_in=x,
                         points_are_rows=true)

  @test size(umatOut, 1) == 100
  @test size(umatOut, 2) == 4
  @test typeof(umatOut[1, 1]) == UInt64
  for i in [0, 1, 3]
    for j in 1:100
      @test umatOut[j, i + 1] == x[j, i + 1]
    end
  end

  for j in 1;100
    @test umatOut[j, 3] == 2 * x[j, 3]
  end
end

# Same as TestMatrix but with an unsigned column major matrix.
@testset "TestUMatrixColMajor" begin
  # Generate a random matrix of integers.
  x = convert(Array{UInt64, 2}, rand(1:500, (5, 100)))

  _, _, _, _, _, _, _, _, _, _, _, umatOut, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         umatrix_in=x)

  @test size(umatOut, 1) == 4
  @test size(umatOut, 2) == 100
  @test typeof(umatOut[1, 1]) == UInt64
  for i in 1:100
    for j in [0, 1, 3]
      @test umatOut[j + 1, i] == x[j + 1, i]
    end
  end

  for j in 1;100
    @test umatOut[3, j] == 2 * x[3, j]
  end
end

# Test a column vector input parameter.
@testset "TestCol" begin
  x = rand(100)

  colOut, _, _, _, _, _, _, _, _, _, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         col_in=x)

  @test size(colOut, 1) == 100
  @test typeof(colOut) == Array{Float64, 1}

  for i in 1:100
    @test colOut[i] == 2 * x[i]
  end
end

# Test an unsigned column vector input parameter.
@testset "TestUCol" begin
  x = convert(Array{UInt64, 1}, rand(1:500, 100))

  _, _, _, _, _, _, _, _, _, _, ucolOut, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         ucol_in=x)

  @test size(ucolOut, 1) == 100
  @test typeof(ucolOut) == Array{UInt64, 1}
  for i in 1:100
    @test ucolOut[i] == 2 * x[i]
  end
end

# Test a row vector input parameter.
@testset "TestRow" begin
  x = rand(100)

  _, _, _, _, _, _, _, rowOut, _, _, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         row_in=x)

  @test size(rowOut, 1) == 100
  @test typeof(rowOut) == Array{Float64, 1}
  for i in 1:100
    @test rowOut[i] == 2 * x[i]
  end
end

# Test an unsigned row vector input parameter.
@testset "TestURow" begin
  x = convert(Array{UInt64, 1}, rand(1:500, 100))

  _, _, _, _, _, _, _, _, _, _, _, _, urowOut, _ =
      test_julia_binding(4.0, 12, "hello",
                         urow_in=x)

  @test size(urowOut, 1) == 100
  @test typeof(urowOut) == Array{UInt64, 1}
  for i in 1:100
    @test urowOut[i] == 2 * x[i]
  end
end

# Test that we can pass a matrix with all numeric features.
@testset "TestMatrixAndInfo" begin
  x = rand(Float64, (10, 100))
  # Dimension information.
  dims = [false, false, false, false, false, false, false, false, false, false]
  z = x

  _, _, _, matrix_and_info_out, _, _, _,  _, _, _, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         matrix_and_info_in=(dims, z),
                         points_are_rows=false)

  @test size(matrix_and_info_out, 1) == 10
  @test size(matrix_and_info_out, 2) == 100

  for i in 1:100
    for j in 1:10
      @test matrix_and_info_out[j, i] == 2.0 * z[j, i]
    end
  end
end

# Test that we can pass a matrix with all numeric features.
@testset "TestMatrixAndInfoRowMajor" begin
  x = rand(Float64, (100, 10))
  # Dimension information.
  dims = [false, false, false, false, false, false, false, false, false, false]
  z = x

  _, _, _, matrix_and_info_out, _, _, _,  _, _, _, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         matrix_and_info_in=(dims, z),
                         points_are_rows=true)

  @test size(matrix_and_info_out, 1) == 100
  @test size(matrix_and_info_out, 2) == 10

  for i in 1:100
    for j in 1:10
      @test matrix_and_info_out[i, j] == 2.0 * z[i, j]
    end
  end
end

# Test that we can pass a vector of ints and get back that same vector but with
# the last element removed.
@testset "TestIntVector" begin
  x = [1, 2, 3, 4, 5]

  _, _, _, _, _, _, _, _, _, _, _, _, _, vecOut =
      test_julia_binding(4.0, 12, "hello",
                         vector_in=x)

  @test vecOut == [1, 2, 3, 4]
end

# Test that we can pass a vector of strings and get back that same vector but
# with the last element removed.
@testset "TestStringVector" begin
  x = ["one", "two", "three", "four", "five"]

  _, _, _, _, _, _, _, _, strVecOut, _, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         str_vector_in=x)

  @test strVecOut == ["one", "two", "three", "four"]
end

# First create a GaussianKernel object, then send it back and make sure we get
# the right double value.
@testset "TestModel" begin
  _, _, _, _, _, _, modelOut, _, _, _, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         build_model=true)

  _, _, _, _, _, bwOut, _, _, _, _, _, _, _, _ =
      test_julia_binding(4.0, 12, "hello",
                         model_in=modelOut)

  @test bwOut == 20.0
end
