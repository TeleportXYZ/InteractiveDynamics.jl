# # Visualizations and Animations for Agent Based Models
# ```@raw html
# <video width="100%" height="auto" controls autoplay loop>
# <source src="https://raw.githubusercontent.com/JuliaDynamics/JuliaDynamics/master/videos/interact/agents.mp4?raw=true" type="video/mp4">
# </video>
# ```

# This page describes functions that can be used in conjunction with
# [Agents.jl](https://juliadynamics.github.io/Agents.jl/dev/) to animate and interact
# with agent based models.

# The animation at the start of the page is created using the code of this page, see below.

# The docs are built using versions:
using Pkg
Pkg.status(["Agents", "InteractiveDynamics", "CairoMakie"];
    mode = PKGMODE_MANIFEST, io=stdout
)

# ## Static plotting of ABMs
# Static plotting, which is also the basis for creating custom plots that include
# an abm plot, is done using the [`abmplot`](@ref) function. Its usage is exceptionally
# straight-forward, and in principle one simply defines functions for how the
# agents should be plotted. Here we will use a pre-defined model, the Daisyworld
# as an example throughout this docpage.
# To learn about this model you can visit the [example hosted at AgentsExampleZoo
# ](https://juliadynamics.github.io/AgentsExampleZoo.jl/dev/examples/daisyworld/),
using InteractiveDynamics, Agents
using CairoMakie
daisypath = joinpath(dirname(pathof(InteractiveDynamics)), "agents", "daisyworld_def.jl")
include(daisypath)
model, daisy_step!, daisyworld_step! = daisyworld(;
    solar_luminosity = 1.0, solar_change = 0.0, scenario = :change
)
model

# Now, to plot daisyworld is as simple as
daisycolor(a::Daisy) = a.breed # color of agents
as = 20 # size of agents
am = '✿' # marker of agents
scatterkwargs = (strokewidth = 1.0,) # add stroke around each agent
fig, ax, abmobs = abmplot(model; ac = daisycolor, as, am, scatterkwargs)
fig

# To this, we can also plot the temperature of the planet by providing the access field
# as a heat array:
heatarray = :temperature
heatkwargs = (colorrange = (-20, 60), colormap = :thermal)
plotkwargs = (;
    ac = daisycolor, as, am,
    scatterkwargs = (strokewidth = 1.0,),
    heatarray, heatkwargs
)

fig, ax, abmobs = abmplot(model; plotkwargs...)
fig


# ```@docs
# abmplot
# ```

# ## Interactive ABM Applications
# Continuing from the Daisyworld plots above, we can turn them into interactive
# applications straightforwardly, simply by providing the stepping functions
# as illustrated in the documentation of [`abmplot`](@ref).
# Note that [`GLMakie`](https://makie.juliaplots.org/v0.15/documentation/backends_and_output/)
# should be used instead of `CairoMakie` when wanting to use the interactive
# aspects of the plots.
fig, ax, abmobs = abmplot(model;
    agent_step! = daisy_step!, model_step! = daisyworld_step!,
    plotkwargs...)
fig

# One could click the run button and see the model evolve.
# Furthermore, one can add more sliders that allow changing the model parameters.
params = Dict(
    :surface_albedo => 0:0.01:1,
    :solar_change => -0.1:0.01:0.1,
)
fig, ax, abmobs = abmplot(model;
    agent_step! = daisy_step!, model_step! = daisyworld_step!,
    params, plotkwargs...)
fig

# One can furthermore collect data while the model evolves and visualize them using the
# convenience function [`abmexploration`](@ref)
using Statistics: mean
black(a) = a.breed == :black
white(a) = a.breed == :white
adata = [(black, count), (white, count)]
temperature(model) = mean(model.temperature)
mdata = [temperature, :solar_luminosity]
fig, abmobs = abmexploration(model;
    agent_step! = daisy_step!, model_step! = daisyworld_step!, params, plotkwargs...,
    adata, alabels = ["Black daisys", "White daisys"], mdata, mlabels = ["T", "L"]
)
nothing # hide

# ```@raw html
# <video width="100%" height="auto" controls autoplay loop>
# <source src="https://raw.githubusercontent.com/JuliaDynamics/JuliaDynamics/master/videos/interact/agents.mp4?raw=true" type="video/mp4">
# </video>
# ```

# ```@docs
# abmexploration
# ```

# ## ABM Videos
# ```@docs
# abmvideo
# ```
# E.g., continuing from above,
model, daisy_step!, daisyworld_step! = daisyworld()
abmvideo(
    "daisyworld.mp4",
    model,  daisy_step!, daisyworld_step!;
    title = "Daisy World", frames = 150,
    plotkwargs...
)

# ```@raw html
# <video width="auto" controls autoplay loop>
# <source src="../daisyworld.mp4" type="video/mp4">
# </video>
# ```


# ## Agent inspection

# It is possible to inspect agents at a given position by hovering the mouse cursor over
# the scatter points in the agent plot. Inspection is automatically enabled for interactive
# applications (i.e. when either agent or model stepping functions are provided). To
# manually enable this functionality, simply add `enable_inspection = true` as an
# additional keyword argument to the `abmplot`/`abmplot!` call.
# A tooltip will appear which by default provides the name of the agent type, its `id`,
# `pos`, and all other fieldnames together with their current values. This is especially
# useful for interactive exploration of micro data on the agent level.

# ![RabbitFoxHawk inspection example](https://github.com/JuliaDynamics/JuliaDynamics/tree/master/videos/agents/RabbitFoxHawk_inspection.png)

# The tooltip can be customized by extending `InteractiveDynamics.agent2string`.
# ```@docs
# InteractiveDynamics.agent2string
# ```

# ## Creating custom ABM plots
# The existing convenience function [`abmexploration`](@ref) will
# always display aggregated collected data as scatterpoints connected with lines.
# In cases where more granular control over the displayed plots is needed, we need to take
# a few extra steps and utilize the [`ABMObservable`](@ref) returned by [`abmplot`](@ref).
# The same steps are necessary when we want to create custom plots that compose
# animations of the model space and other aspects.

# ```@docs
# ABMObservable
# ```
# To do custom animations you need to have a good idea of how Makie's animation system works.
# Have a look [at this tutorial](https://www.youtube.com/watch?v=L-gyDvhjzGQ) if you are
# not familiar yet.

# create a basic abmplot with controls and sliders
model, = daisyworld(; solar_luminosity = 1.0, solar_change = 0.0, scenario = :change)
fig, ax, abmobs = abmplot(model;
    agent_step! = daisy_step!, model_step! = daisyworld_step!, params, plotkwargs...,
    adata, mdata, figure = (; resolution = (1600,800))
)
fig

#

abmobs

#

# create a new layout to add new plots to to the right of the abmplot
plot_layout = fig[:,end+1] = GridLayout()

# create a sublayout on its first row and column
count_layout = plot_layout[1,1] = GridLayout()

# collect tuples with x and y values for black and white daisys
blacks = @lift(Point2f.($(abmobs.adf).step, $(abmobs.adf).count_black))
whites = @lift(Point2f.($(abmobs.adf).step, $(abmobs.adf).count_white))

# create an axis to plot into and style it to our liking
ax_counts = Axis(count_layout[1,1];
    backgroundcolor = :lightgrey, ylabel = "Number of daisies by color")

# plot the data as scatterlines and color them accordingly
scatterlines!(ax_counts, blacks; color = :black, label = "black")
scatterlines!(ax_counts, whites; color = :white, label = "white")

# add a legend to the right side of the plot
Legend(count_layout[1,2], ax_counts; bgcolor = :lightgrey)

# and another plot, written in a more condensed format
ax_hist = Axis(plot_layout[2,1];
    ylabel = "Distribution of mean temperatures\nacross all time steps")
hist!(ax_hist, @lift($(abmobs.mdf).temperature);
    bins = 50, color = :red,
    strokewidth = 2, strokecolor = (:black, 0.5),
)

fig

# Now, once we step the `abmobs::ABMObservable`, the whole plot will be updated
Agents.step!(abmobs, 1)
Agents.step!(abmobs, 1)
fig

# Of course, you need to actually adjust axis limits given that the plot is interactive
autolimits!(ax_counts)
autolimits!(ax_hist)

# Or, simply trigger them on any update to the model observable:
on(abmobs.model) do m
    autolimits!(ax_counts)
    autolimits!(ax_hist)
end

# and then marvel at everything being auto-updated by calling `step!` :)

for i in 1:100; step!(abmobs, 1); end
fig