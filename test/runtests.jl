#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport
using Test
import Random
using FMIZoo

using FMIImport.FMICore: fmi2Integer, fmi2Boolean, fmi2Real, fmi2String
using FMIImport.FMICore: fmi3Float32, fmi3Float64, fmi3Int8, fmi3UInt8, fmi3Int16, fmi3UInt16, fmi3Int32, fmi3UInt32, fmi3Int64, fmi3UInt64
using FMIImport.FMICore: fmi3Boolean, fmi3String, fmi3Binary

import FMIImport.FMICore: FMU2_EXECUTION_CONFIGURATION_NO_FREEING, FMU2_EXECUTION_CONFIGURATION_NO_RESET, FMU2_EXECUTION_CONFIGURATION_RESET, FMU2_EXECUTION_CONFIGURATION_NOTHING
import FMIImport.FMICore: FMU3_EXECUTION_CONFIGURATION_NO_FREEING, FMU3_EXECUTION_CONFIGURATION_NO_RESET, FMU3_EXECUTION_CONFIGURATION_RESET

exportingToolsWindows = [("Dymola", "2022x")]
exportingToolsLinux = [("Dymola", "2022x")]

function runtestsFMI2(exportingTool)
    ENV["EXPORTINGTOOL"] = exportingTool[1]
    ENV["EXPORTINGVERSION"] = exportingTool[2]

    # enable assertions for warnings/errors for all default execution configurations 
    for exec in [FMU2_EXECUTION_CONFIGURATION_NO_FREEING, FMU2_EXECUTION_CONFIGURATION_NO_RESET, FMU2_EXECUTION_CONFIGURATION_RESET, FMU2_EXECUTION_CONFIGURATION_NOTHING]
        exec.assertOnError = true
        exec.assertOnWarning = true
    end

    @testset "Testing FMUs exported from $exportingTool" begin
        @testset "Functions for FMU2Component" begin
            @testset "Variable Getters / Setters" begin
                include("FMI2/getter_setter.jl")
            end
            @testset "State Manipulation" begin
                include("FMI2/state.jl")
            end
            @testset "Sensitivities" begin
                include("FMI2/sensitivities.jl")
            end
        end

        @testset "Model Description Parsing" begin
            include("FMI2/model_description.jl")
        end

        @testset "Logging" begin
            include("FMI2/logging.jl")
        end
        @testset "Logging with externalCallbacks" begin
            include("FMI2/externalLogging.jl")
        end
    end
end

function runtestsFMI3(exportingTool)
    ENV["EXPORTINGTOOL"] = exportingTool[1]
    ENV["EXPORTINGVERSION"] = exportingTool[2]

    # enable assertions for warnings/errors for all default execution configurations 
    for exec in [FMU3_EXECUTION_CONFIGURATION_NO_FREEING, FMU3_EXECUTION_CONFIGURATION_NO_RESET, FMU3_EXECUTION_CONFIGURATION_RESET]
        exec.assertOnError = true
        exec.assertOnWarning = true
    end

    @testset "Testing FMUs exported from $exportingTool" begin
        @testset "Functions for fmi3Instance" begin
            @testset "Variable Getters / Setters" begin
                include("FMI3/getter_setter.jl")
            end
            @testset "State Manipulation" begin
                include("FMI3/state.jl")
            end
            @testset "Directional derivatives" begin
                @warn "Skipping FMI3 directional derivative testing..."
                #include("FMI3/dir_ders.jl")
            end
        end

        @testset "Model Description Parsing" begin
            include("FMI3/model_description.jl")
        end

        @testset "Logging" begin
            include("FMI3/logging.jl")
        end
    end
end

@testset "FMIImport.jl" begin
    if Sys.iswindows()
        @info "Automated testing is supported on Windows."
        for exportingTool in exportingToolsWindows
            runtestsFMI2(exportingTool)
            runtestsFMI3(exportingTool)
        end
    elseif Sys.islinux()
        @info "Automated testing is supported on Linux."
        for exportingTool in exportingToolsLinux
            runtestsFMI2(exportingTool)
            runtestsFMI3(exportingTool)
        end
    elseif Sys.isapple()
        @warn "Test-sets are currrently using Windows- and Linux-FMUs, automated testing for macOS is currently not supported."
    end
end
