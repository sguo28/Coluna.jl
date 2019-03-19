struct Membership{VCT <: AbstractVarConstr}
    member_coef_map::SparseVector{Float64,Id{VCT}}
end

function get_coeff(m::Membership{T}, id::Id{T}) where {T <: AbstractVarConstr}
    return m.member_coef_map[id.id]
end

mutable struct Manager{VCT <: AbstractVarConstr}
    vc_list::SparseVector{AbstractMoiDef, Id{VCT}}
    active_mask::SparseVector{Bool,Id{VCT}}
    static_mask::SparseVector{Bool,Id{VCT}}
end

# getlist(m::Manager{Constraint}) = m.vc_list::SparseVector{MoiConstrDef, Id{Constraint}}
# getlist(m::Manager{Variable}) = m.vc_list::SparseVector{MoiVarDef, Id{Variable}}

Manager{T}() where {T <: AbstractVarConstr} = Manager{T}(spzeros(0), spzeros(0), spzeros(0))

function get_list(m::Manager, active::Bool, static::Bool)
    if active
        static && return m.vc_list[m.active_mask .& m.static_mask]
        !static && return m.vc_list[m.active_mask .& !m.static_mask]
    end
    static && return  m.vc_list[!m.active_mask .& m.static_mask]
    return m.vc_list[!m.active_mask .& m.dynamic_mask]
end

function get_active_list(m::Manager, active::Bool)
    if active
        return m.vc_list[m.active_mask]
    end
    return m.vc_list[!m.active_mask]
end

function get_static_list(m::Manager, static::Bool)
    if static
        return m.vc_list[m.static_mask]
    end
    return m.vc_list[!m.static_mask]
end

function add_in_manager(m::Manager{T}, elem::T, active::Bool, static::Bool) where {T <: AbstractVarConstr}
    m.vc_list[elem.uid] = elem
    active_mask[elem.uid] = active
    static_mask[elem.uid] = active   
    return
end

function remove_from_manager(m::Manager{T}, elem::T) where {T <: AbstractVarConstr}
    deleteat!(m.vc_list, elem.uid)
    deleteat!(m.active_mask, elem.uid)
    deleteat!(m.static_mask, elem.uid)
    return
end

