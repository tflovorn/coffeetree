class Vector
    constructor: (@x, @y) ->

    add: (other) ->
        new Vector(@x + other.x, @y + other.y)

    sub: (other) ->
        new Vector(@x - other.x, @y - other.y)

    mult: (scalar) ->
        new Vector(scalar * @x, scalar * @y)

    toString: -> "(#{@x}, #{@y})"

# An individual node (square) in the Pythagoras tree
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

    toString: -> "{X:#{@basisX}, Y:#{@basisY}, O:#{@origin}, L:#{@left}, R:#{@right}}"

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

    # Render the whole tree on to the given image
    render: (image) ->

    toString: -> @root.toString()

alert (new PythagorasTree(1.0, Math.PI / 4, 1)).toString()
