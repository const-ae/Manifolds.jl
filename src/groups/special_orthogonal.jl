@doc raw"""
    SpecialOrthogonal{n} = SpecialUnitary{n,ℝ}

Special orthogonal group $\mathrm{SO}(n)$ represented by rotation matrices.

# Constructor
    SpecialOrthogonal(n)
"""
const SpecialOrthogonal{n} = SpecialUnitary{n,ℝ}

invariant_metric_dispatch(::SpecialOrthogonal, ::ActionDirection) = Val(true)

function default_metric_dispatch(
    ::MetricManifold{𝔽,<:SpecialOrthogonal,EuclideanMetric},
) where {𝔽}
    return Val(true)
end
default_metric_dispatch(::SpecialOrthogonal, ::EuclideanMetric) = Val(true)

SpecialOrthogonal(n) = SpecialOrthogonal{n}()

Base.show(io::IO, ::SpecialOrthogonal{n}) where {n} = print(io, "SpecialOrthogonal($(n))")
