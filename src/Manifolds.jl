module Manifolds

import Base:
    Array,
    +,
    -,
    *,
    \,
    /,
    ^,
    ==,
    angle,
    axes,
    convert,
    copy,
    copyto!,
    dataids,
    eltype,
    exp,
    getindex,
    identity,
    inv,
    isapprox,
    length,
    log,
    one,
    promote_rule,
    setindex!,
    show,
    similar,
    size,
    transpose,
    zero
import Distributions: _rand!, support
import LinearAlgebra: cross, det, Diagonal, dot, mul!, norm, I, UniformScaling
import ManifoldsBase:
    allocate,
    allocate_result,
    allocate_result_type,
    array_value,
    base_manifold,
    check_manifold_point,
    check_tangent_vector,
    distance,
    exp,
    exp!,
    geodesic,
    injectivity_radius,
    inner,
    isapprox,
    is_manifold_point,
    is_tangent_vector,
    is_decorator_manifold,
    inverse_retract,
    inverse_retract!,
    log,
    log!,
    manifold_dimension,
    norm,
    number_eltype,
    project_point,
    project_point!,
    project_tangent,
    project_tangent!,
    representation_size,
    retract,
    retract!,
    shortest_geodesic,
    vector_transport_along,
    vector_transport_along!,
    vector_transport_direction,
    vector_transport_direction!,
    vector_transport_to,
    vector_transport_to!,
    zero_tangent_vector,
    zero_tangent_vector!
import Random: rand
import Statistics: mean, mean!, median, median!, std, var
import StatsBase: kurtosis, mean_and_std, mean_and_var, moment, skewness

using Base.Iterators: repeated
using Distributions
using Einsum: @einsum
using FiniteDifferences
using HybridArrays
using LinearAlgebra
using LightGraphs
using LightGraphs: AbstractGraph
using ManifoldsBase: CoTVector, Manifold, MPoint, TVector, DefaultManifold
using ManifoldsBase:
    ArrayCoTVector, ArrayManifold, ArrayMPoint, ArrayTVector, ArrayCoTVector
using ManifoldsBase: AbstractRetractionMethod, ExponentialRetraction
using ManifoldsBase: AbstractInverseRetractionMethod, LogarithmicInverseRetraction
using ManifoldsBase: AbstractVectorTransportMethod, ParallelTransport, ProjectionTransport
using Markdown: @doc_str
using Random: AbstractRNG
using Requires
using SimpleWeightedGraphs: AbstractSimpleWeightedGraph, get_weight
using StaticArrays
using StatsBase: AbstractWeights, UnitWeights, values, varcorrection
using UnsafeArrays

"""
    AbstractEstimationMethod

Abstract type for defining statistical estimation methods.
"""
abstract type AbstractEstimationMethod end

"""
    PolarRetraction <: AbstractRetractionMethod

Retractions that are based on singular value decompositions of the matrix / matrices
for point and tangent vector on a [`Manifold`](@ref)
"""
struct PolarRetraction <: AbstractRetractionMethod end

"""
    ProjectionRetraction <: AbstractRetractionMethod

Retractions that are based on projection and usually addition in the embedding.
"""
struct ProjectionRetraction <: AbstractRetractionMethod end

"""
    QRRetraction <: AbstractRetractionMethod

Retractions that are based on a QR decomposition of the
matrix / matrices for point and tangent vector on a [`Manifold`](@ref)
"""
struct QRRetraction <: AbstractRetractionMethod end

"""
    PolarInverseRetraction <: AbstractInverseRetractionMethod

Inverse retractions that are based on a singular value decomposition of the
matrix / matrices for point and tangent vector on a [`Manifold`](@ref)
"""
struct PolarInverseRetraction <: AbstractInverseRetractionMethod end

"""
    ProjectionInverseRetraction <: AbstractInverseRetractionMethod

Inverse retractions that are based on a projection (or its inversion).
"""
struct ProjectionInverseRetraction <: AbstractInverseRetractionMethod end

"""
    QRInverseRetraction <: AbstractInverseRetractionMethod

Inverse retractions that are based on a QR decomposition of the
matrix / matrices for point and tangent vector on a [`Manifold`](@ref)
"""
struct QRInverseRetraction <: AbstractInverseRetractionMethod end

include("utils.jl")
include("numbers.jl")
include("bases.jl")
include("autodiff.jl")
include("SizedAbstractArray.jl")

include("manifolds/VectorBundle.jl")

include("distributions.jl")
include("projected_distribution.jl")
include("product_representations.jl")

include("manifolds/MetricManifold.jl")
include("manifolds/ProductManifold.jl")
include("manifolds/PowerManifold.jl")
include("manifolds/GraphManifold.jl")

include("manifolds/CholeskySpace.jl")
include("manifolds/Circle.jl")
include("manifolds/Euclidean.jl")
include("manifolds/FixedRankMatrices.jl")
include("manifolds/Grassmann.jl")
include("manifolds/Hyperbolic.jl")
include("manifolds/Rotations.jl")
include("manifolds/Stiefel.jl")
include("manifolds/Sphere.jl")
include("manifolds/Symmetric.jl")
include("manifolds/SymmetricPositiveDefinite.jl")
include("manifolds/SymmetricPositiveDefiniteLinearAffine.jl")
include("manifolds/SymmetricPositiveDefiniteLogCholesky.jl")
include("manifolds/SymmetricPositiveDefiniteLogEuclidean.jl")
include("manifolds/Torus.jl")

include("groups/group.jl")
include("groups/metric.jl")
include("groups/group_action.jl")
include("groups/group_operation_action.jl")
include("groups/array_manifold.jl")
include("groups/product_group.jl")
include("groups/semidirect_product_group.jl")

include("groups/translation_group.jl")
include("groups/special_orthogonal.jl")
include("groups/circle_group.jl")

include("groups/translation_action.jl")
include("groups/rotation_action.jl")

include("groups/special_euclidean.jl")

include("statistics.jl")

function __init__()
    @require ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210" begin
        using .ForwardDiff
        include("forward_diff.jl")
    end

    @require OrdinaryDiffEq = "1dea7af3-3e70-54e6-95c3-0bf5283fa5ed" begin
        using .OrdinaryDiffEq: ODEProblem, AutoVern9, Rodas5, solve
        include("ode.jl")
    end
end
#
export CoTVector, Manifold, MPoint, TVector, Manifold
export Euclidean,
    CholeskySpace,
    Circle,
    FixedRankMatrices,
    Grassmann,
    Hyperbolic,
    Rotations,
    Sphere,
    Stiefel,
    SymmetricMatrices,
    SymmetricPositiveDefinite,
    Torus
export SVDMPoint, UMVTVector, AbstractNumbers, ℝ, ℂ, ℍ
# decorator manifolds
export ArrayManifold, ArrayMPoint, ArrayTVector, ArrayCoTVector
export CotangentBundle,
    CotangentSpaceAtPoint, CotangentBundleFibers, CotangentSpace, FVector
export AbstractPowerManifold,
    AbstractPowerRepresentation,
    ArrayPowerRepresentation,
    NestedPowerRepresentation,
    PowerManifold
export ProductManifold
export GraphManifold, GraphManifoldType, VertexManifold, EdgeManifold
export ProjectedPointDistribution, ProductRepr, TangentBundle, TangentBundleFibers
export TangentSpace, TangentSpaceAtPoint, VectorSpaceAtPoint, VectorSpaceType, VectorBundle
export VectorBundleFibers
export AbstractVectorTransportMethod, ParallelTransport, ProjectedPointDistribution
export Metric,
    RiemannianMetric,
    LorentzMetric,
    EuclideanMetric,
    LinearAffineMetric,
    LogCholeskyMetric,
    LogEuclideanMetric,
    MinkowskiMetric,
    PowerMetric,
    ProductMetric,
    MetricManifold
export AbstractVectorTransportMethod, ParallelTransport, ProjectionTransport
export AbstractRetractionMethod, QRRetraction, PolarRetraction, ProjectionRetraction
export AbstractInverseRetractionMethod,
    QRInverseRetraction, PolarInverseRetraction, ProjectionInverseRetraction
export AbstractEstimationMethod,
    GradientDescentEstimation,
    CyclicProximalPointEstimation,
    GeodesicInterpolation,
    GeodesicInterpolationWithinRadius
export
    CachedBasis,
    DefaultBasis,
    DefaultOrthogonalBasis,
    DefaultOrthonormalBasis,
    DiagonalizingOrthonormalBasis,
    DefaultOrthonormalBasis
    ProjectedOrthonormalBasis
export ×,
    allocate,
    allocate_result,
    base_manifold,
    bundle_projection,
    christoffel_symbols_first,
    christoffel_symbols_second,
    christoffel_symbols_second_jacobian,
    complex_dot,
    det_local_metric,
    distance,
    einstein_tensor,
    exp,
    exp!,
    flat,
    flat!,
    gaussian_curvature,
    geodesic,
    hat,
    hat!,
    incident_log,
    injectivity_radius,
    inner,
    inverse_local_metric,
    inverse_retract,
    inverse_retract!,
    isapprox,
    is_decorator_manifold,
    is_default_metric,
    is_manifold_point,
    is_tangent_vector,
    isapprox,
    inner,
    kurtosis,
    local_metric,
    local_metric_jacobian,
    log,
    log!,
    log_local_metric_density,
    manifold_dimension,
    metric,
    mean,
    mean!,
    mean_and_var,
    mean_and_std,
    median,
    median!,
    moment,
    norm,
    normal_tvector_distribution,
    number_eltype,
    one,
    power_dimensions,
    project_point,
    project_point!,
    project_tangent,
    project_tangent!,
    projected_distribution,
    real_dimension,
    ricci_curvature,
    ricci_tensor,
    representation_size,
    retract,
    retract!,
    riemann_tensor,
    sharp,
    sharp!,
    shortest_geodesic,
    skewness,
    std,
    sym_rem,
    submanifold,
    submanifold_component,
    submanifold_components,
    uniform_distribution,
    var,
    vector_space_dimension,
    vector_transport_along,
    vector_transport_along!,
    vector_transport_direction,
    vector_transport_direction!,
    vector_transport_to,
    vector_transport_to!,
    vee,
    vee!,
    zero_vector,
    zero_vector!,
    zero_tangent_vector,
    zero_tangent_vector!
# Lie group types & functions
export AbstractGroupAction,
    AbstractGroupOperation,
    AbstractGroupManifold,
    ActionDirection,
    AdditionOperation,
    CircleGroup,
    GroupManifold,
    GroupOperationAction,
    Identity,
    InvariantMetric,
    LeftAction,
    LeftInvariantMetric,
    MultiplicationOperation,
    ProductGroup,
    ProductOperation,
    RightAction,
    RightInvariantMetric,
    RotationAction,
    SemidirectProductGroup,
    SpecialEuclidean,
    SpecialOrthogonal,
    TranslationGroup,
    TranslationAction
export affine_matrix,
    apply,
    apply!,
    apply_diff,
    apply_diff!,
    base_group,
    center_of_orbit,
    check_has_invariant_metric,
    compose,
    compose!,
    direction,
    g_manifold,
    group_exp,
    group_exp!,
    group_log,
    group_log!,
    has_biinvariant_metric,
    has_invariant_metric,
    identity,
    identity!,
    inv,
    inv!,
    inverse_apply,
    inverse_apply!,
    inverse_apply_diff,
    inverse_apply_diff!,
    inverse_translate,
    inverse_translate!,
    inverse_translate_diff,
    inverse_translate_diff!,
    optimal_alignment,
    optimal_alignment!,
    screw_matrix,
    switch_direction,
    translate,
    translate!,
    translate_diff,
    translate_diff!
# Orthonormal bases
export AbstractBasis,
    AbstractOrthonormalBasis,
    DefaultOrthonormalBasis,
    DiagonalizingOrthonormalBasis,
    ProjectedOrthonormalBasis,
    CachedBasis,
    DiagonalizingBasisData,
    ProductBasisData,
    PowerBasisData
export get_basis, get_coordinates, get_vector, get_vectors, number_system
end # module
