class Vector
    constructor: (@x, @y) ->

    add: (other) ->
        new Vector(@x + other.x, @y + other.y)

    subtract: (other) ->
        new Vector(@x - other.x, @y + other.y)

class PythagorasNode
    constructor: (@origin, @basisX, @basisY, @left = null, @right = null) ->

    spawn: (angle) ->

class PythagorasTree
    constructor: (@rootLength, @angle, depth) ->
        # bottom left of root node is at origin of coordinates
        rootOrigin = new Vector(0.0, 0.0)
        rootX = new Vector(rootLength, 0.0)
        rootY = new Vector(0.0, rootLength)
        @root = new PythagorasNode rootOrigin rootX rootY
        expand(depth)

    expand: (extraDepth) ->
        depthToGo = extraDepth
        while depthToGo -= 1
            @root.spawn length angle

    render: (image) ->
