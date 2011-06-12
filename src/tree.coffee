# A two-dimensional vector (@x, @y)
class Vector
    constructor: (@x, @y) ->

    add: (other) ->
        new Vector(@x + other.x, @y + other.y)

    sub: (other) ->
        new Vector(@x - other.x, @y - other.y)

    mult: (scalar) ->
        new Vector(scalar * @x, scalar * @y)

    toString: -> "(#{@x}, #{@y})"

# An individual node (square) in the Pythagoras tree.  The square's bottom-left
# corner is at @origin, and the bases of its local rotated coordinates are 
# @basisX and @basisY.  These bases have length equal to the square's side
# length.  Each node may have two child nodes, @left and @right.
class PythagorasNode
    constructor: (@origin, @basisX, @basisY, @left = null, @right = null) ->

    # Call spawn on @left and @right, if they exist.  If not, create them using
    # the given angle (in radians).
    spawn: (angle) ->
        newNodes = []
        if @left?
            newNodes.concat(@left.spawn angle)
        else
            [cos, sin] = [Math.cos(angle), Math.sin(angle)]
            leftOrigin = @origin.add(@basisY)
            leftX = @basisX.mult(cos * cos).add(@basisY.mult(sin * cos))
            leftY = @basisX.mult(-sin * cos).add(@basisY.mult(cos * cos))
            @left = new PythagorasNode(leftOrigin, leftX, leftY)
            newNodes.push(@left)
        if @right?
            newNodes.concat(@right.spawn angle)
        else
            [cos, sin] = [Math.cos(angle), Math.sin(angle)]
            rightOrigin = @origin.add(@basisX.mult(cos * cos).add(@basisY.mult(sin * cos + 1)))
            rightX = @basisX.mult(sin * sin).sub(@basisY.mult(sin * cos))
            rightY = @basisX.mult(sin * cos).add(@basisY.mult(sin * sin))
            @right = new PythagorasNode(rightOrigin, rightX, rightY)
            newNodes.push(@right)
        return newNodes

    # return the boundaries of this square and its children
    bounds: ->
        leftBounds = @left?.bounds()
        rightBounds = @right?.bounds()
        boundAll(@localBounds(), leftBounds, rightBounds)

    # return the boundaries [(xmin, ymin), (xmax, ymax)] of this square
    localBounds: ->

    toString: -> "{X:#{@basisX}, Y:#{@basisY}, O:#{@origin}, L:#{@left}, R:#{@right}}"

# return the area defined by [(xmin, ymin), (xmax, ymax)] within the boundaries
boundAll: (boundaries...) ->

# A representation of the Pythagoras tree in its own coordinate system.
class PythagorasTree
    constructor: (@rootLength, @angle, depth) ->
        # bottom left of root node is at origin of tree coordinates
        rootOrigin = new Vector(0.0, 0.0)
        rootX = new Vector(rootLength, 0.0)
        rootY = new Vector(0.0, rootLength)
        @root = new PythagorasNode(rootOrigin, rootX, rootY)
        @expand(depth)

    # Create nodes up to the given extra depth
    expand: (extraDepth) ->
        depthToGo = extraDepth + 1
        while depthToGo -= 1
            @root.spawn @angle

    bounds: ->
        @root.bounds()

    # Render the whole tree on to the given image
    render: (image) ->

    toString: -> @root.toString()

alert (new PythagorasTree(1.0, Math.PI / 4, 1)).toString()
