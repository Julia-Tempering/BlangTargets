module BlangTargets

using Pigeons 
using CSV


function build_targets_db() 
    for blang_lib in Pigeons.precompiled_blang_libs 
        Pigeons.setup_blang(blang_lib) 
    end
    result = Dict{Symbol, Any}()
    csv_file = "$(Pigeons.mpi_settings_folder())/blangDemos/src/main/resources/demos/models.csv"
    for row in CSV.File(csv_file)
        result[Symbol(row.name)] = row
    end
    result[:sitka] = nothing
    return result
end
const target_db = build_targets_db() 

provide_targetIds() = keys(target_db)
function provide_target(targetId::Symbol)
    if targetId == :sitka
        return Pigeons.blang_sitka()
    end
    specs = target_db[targetId]
    model_options = ismissing(specs.arguments) ? `` : Cmd(Base.shell_split(specs.arguments))
    return Pigeons.BlangTarget(`$(Pigeons.blang_executable("blangDemos", specs.class)) $model_options`)
end

Pigeons.extract_sample(state::Pigeons.StreamState, log_potential) = [log_potential(state)]
Pigeons.sample_names(::Pigeons.StreamState, _) = [:logd]

end