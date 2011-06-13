# A two-dimensional vector (@x, @y)
class Vector
    constructor: (@x, @y) ->

    add: (other) ->
        new Vector(@x + other.x, @y + other.y)

    sub: (other) ->
        new Vector(@x - other.x, @y - other.y)

    dot: (other) ->
        @x * other.x + @y * other.y

    mult: (scalar) ->
        new Vector(scalar * @x, scalar * @y)

    normSquared: ->
        @dot(this)

    toString: -> "(#{@x}, #{@y})"

# An individual node (square) in the Pythagoras tree.  The square's bottom-left
# corner is at @origin, and the bases of its local rotated coordinates are 
# @basisX and @basisY.  These bases have length equal to the square's side
# length.  Each node may have two child nodes, @left and @right.
class PythagorasNode
    constructor: (@origin, @basisX, @basisY, @left = null, @right = null) ->

    # Call spawn on @left and @right, if they exist.  If not, create them using
    # the given angle (in radians).  Return a list of all new nodes created by
    # this function on this node and its children.
    spawn: (angle) ->
        newNodes = []
        [cos, sin] = [Math.cos(angle), Math.sin(angle)]
        if @left?
            newNodes.concat(@left.spawn angle)
        else
            leftOrigin = @origin.add(@basisY)
            leftX = @basisX.mult(cos * cos).add(@basisY.mult(sin * cos))
            leftY = @basisX.mult(-sin * cos).add(@basisY.mult(cos * cos))
            @left = new PythagorasNode(leftOrigin, leftX, leftY)
            newNodes.push(@left)
        if @right?
            newNodes.concat(@right.spawn angle)
        else
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

    # return the boundaries [(xMin, yMin), (xMax, yMax)] of the smallest square
    # aligned with the global x-y coordinates containing this square
    localBounds: ->
        corners = [
            @origin                             # bottom left
            @origin.add(@basisX)                # bottom right
            @origin.add(@basisY)                # top left
            @origin.add(@basisX).add(@basisY)   # top right
        ]
        # need to initialize to some point in the square
        [xMin, yMin] = [@origin.x, @origin.y]
        [xMax, yMax] = [xMin, yMin]
        # look through all points and find real min and max
        for point in corners
            [xMin, yMin] = [Math.min(xMin, point.x), Math.min(yMin, point.y)]
            [xMax, yMax] = [Math.max(xMax, point.x), Math.max(yMax, point.y)]
        return {min:new Vector(xMin, yMin), max:new Vector(xMax, yMax)}

    # Return true if the point at the upper-right corner of pixel is within
    # this node, otherwise return false.  pixel is a pair [nx, ny] of pixel 
    # indices. globalBounds is the bounds of the whole tree, and pixelNums is 
    # the pair [Nx, Ny] containing the total number of pixels in each direction.
    pixelHit: (globalBounds, pixelNums, pixel) ->
        scaleX = (globalBounds.max.x - globalBounds.min.x) / pixelNums[0]
        scaleY = (globalBounds.max.y - globalBounds.min.y) / pixelNums[1]
        # -- unfinished -- #

    toString: -> "{X:#{@basisX}, Y:#{@basisY}, O:#{@origin}, L:#{@left}, R:#{@right}}"

# Return the pair of points {min:(xMin, yMin), max:(xMax, yMax)}, where 
# (xMin, yMin) are the minimum values of x and y in the given boundaries, and 
# (xMax, yMax) are the maximum values.  boundaries is a list of points of the 
# same form.
boundAll = (boundaries...) ->
    # return null if boundaries.length is 0 or nonexistant.
    if !boundaries.length? then return null
    # declare these to fix scope
    [xMin, yMin] = [null, null]
    [xMax, yMax] = [null, null]
    for bounds in boundaries when bounds?
        # initialize min/max to first non-null bounds
        if !xMin?   # if one is null, all others are too
            [xMin, yMin] = [bounds.min.x, bounds.min.y]
            [xMax, yMax] = [bounds.max.x, bounds.max.y]
        # min/max have been initialized, check if they should change
        else
            [xMin, yMin] = [
                Math.min(xMin, bounds.min.x)
                Math.min(yMin, bounds.min.y)
            ]
            [xMax, yMax] = [
                Math.max(xMax, bounds.max.x)
                Math.max(yMax, bounds.max.y)
            ]
    {min: new Vector(xMin, yMin), max: new Vector(xMax, yMax)}

# A representation of the Pythagoras tree in its own coordinate system.
class PythagorasTree
    constructor: (@rootLength, @angle, order) ->
        # bottom left of root node is at origin of tree coordinates
        rootOrigin = new Vector(0.0, 0.0)
        rootX = new Vector(rootLength, 0.0)
        rootY = new Vector(0.0, rootLength)
        @root = new PythagorasNode(rootOrigin, rootX, rootY)
        @expand(order)

    # Create nodes up to the given extra depth
    expand: (extraDepth) ->
        depthToGo = extraDepth + 1
        while depthToGo -= 1
            @root.spawn @angle

    # Return the boundary points for the whole tree.
    bounds: ->
        @root.bounds()

    # Render the whole tree on to the given image
    render: (image) ->

    toString: -> @root.toString()

module.exports = {PythagorasTree: PythagorasTree, Vector:Vector}
