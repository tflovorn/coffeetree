NEW_PIXEL = [0, 0, 0, 0]
GREY_PIXEL = [120, 120, 120, 120]
BLACK_PIXEL = [0, 0, 0, 255]

checkPixel = (data, idx, pixel) ->
    for i in [0...4] when data[idx + i] != pixel[i]
        return false
    true

setPixel = (data, idx, pixel) ->
    for i in [0...4]
        data[idx + i] = pixel[i]
    data

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
    constructor: (@origin, @basisX, @basisY, @color, @left = null, @right = null) ->

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
            @left = new PythagorasNode(leftOrigin, leftX, leftY, @color)
            newNodes.push(@left)
        if @right?
            newNodes.concat(@right.spawn angle)
        else
            rightOrigin = @origin.add(@basisX.mult(cos * cos).add(@basisY.mult(sin * cos + 1)))
            rightX = @basisX.mult(sin * sin).sub(@basisY.mult(sin * cos))
            rightY = @basisX.mult(sin * cos).add(@basisY.mult(sin * sin))
            @right = new PythagorasNode(rightOrigin, rightX, rightY, @color)
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

    # Return true if the point at the center of pixel is within this node, 
    # otherwise return false.  pixel is a pair [nx, ny] of pixel indices. 
    # globalBounds is the bounds of the whole tree, and pixelNums is the pair
    # [Nx, Ny] containing the total number of pixels in each direction.
    pixelHit: (globalBounds, pixelNums, pixel) ->
        [nx, ny] = pixel
        scaleX = (globalBounds.max.x - globalBounds.min.x) / pixelNums[0]
        scaleY = (globalBounds.max.y - globalBounds.min.y) / pixelNums[1]
        scale = Math.max(scaleX, scaleY)
        [scaleX, scaleY] = [scale, scale]
        localPoint = new Vector(globalBounds.min.x + scaleX * (nx + 0.5) - @origin.x, globalBounds.max.y - scaleY * (ny + 0.5) - @origin.y)
        hitX = 0.0 <= localPoint.dot(@basisX) <= @basisX.normSquared()
        hitY = 0.0 <= localPoint.dot(@basisY) <= @basisY.normSquared()
        hitX and hitY

    # Return all pixels within the local bounds (all pixels that could possibly
    # be hits).
    allPossiblePixels: (globalBounds, pixelNums) ->
        scaleX = (globalBounds.max.x - globalBounds.min.x) / pixelNums[0]
        scaleY = (globalBounds.max.y - globalBounds.min.y) / pixelNums[1]
        scale = Math.max(scaleX, scaleY)
        [scaleX, scaleY] = [scale, scale]
        localBounds = @localBounds()
        [bottomLeft, topRight] = [localBounds.min, localBounds.max]
        nxBL = Math.floor((bottomLeft.x - globalBounds.min.x) / scaleX)
        nyBL = Math.ceil((globalBounds.max.y - bottomLeft.y) / scaleY) - 1
        nxTR = Math.ceil((topRight.x - globalBounds.min.x) / scaleX) - 1
        nyTR = Math.floor((globalBounds.max.y - topRight.y) / scaleY)
        candidates = []
        for ny in [nyTR..nyBL]
           for nx in [nxBL..nxTR]
                candidates.push([nx, ny])
        candidates

    # Return all pixels this node actually hits.
    allHitPixels: (globalBounds, pixelNums) ->
        (pixel for pixel in @allPossiblePixels(globalBounds, pixelNums) when @pixelHit(globalBounds, pixelNums, pixel))

    # Render the node and its children to the ImageData image.
    render: (image, globalBounds) ->
        pixelNums = [image.width, image.height]
        data = image.data
        for pixel in @allHitPixels(globalBounds, pixelNums)
            idx = (pixel[1] * pixelNums[0] + pixel[0]) * 4
            if checkPixel(data, idx, NEW_PIXEL)
                setPixel(data, idx, @color)
        @left?.render(image, globalBounds)
        @right?.render(image, globalBounds)

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
    constructor: (@rootLength, @angle, order, color) ->
        # bottom left of root node is at origin of tree coordinates
        rootOrigin = new Vector(0.0, 0.0)
        rootX = new Vector(rootLength, 0.0)
        rootY = new Vector(0.0, rootLength)
        @root = new PythagorasNode(rootOrigin, rootX, rootY, color)
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
        @root.render(image, @bounds())

    toString: ->
        @root.toString()

if document?
    context = canvas.getContext '2d'
    [width, height] = [canvas.width, canvas.height]
    image = context.createImageData(width, height)
    someTree = new PythagorasTree(1.0, Math.PI / 4.0, 12, BLACK_PIXEL)
    someTree.render(image)
    context.putImageData(image, 0, 0)
    # attaching this to document seems like a ridiculous hack
    # (but it works, so...)
    document.newInput = ->
        context = canvas.getContext '2d'
        [width, height] = [canvas.width, canvas.height]
        image = context.createImageData(width, height)
        color = cutHex(settings.setcolor.value)
        rgb = [hexToR(color), hexToG(color), hexToB(color), 255]
        angle = settings.setangle.value * Math.PI / 180 # want radians
        someTree = new PythagorasTree(1.0, angle, 12, rgb)
        someTree.render(image)
        context.putImageData(image, 0, 0)

# stolen shamelessly from http://www.javascripter.net/faq/hextorgb.htm
hexToR = (h) ->
    parseInt((cutHex(h)).substring(0,2),16)
hexToG = (h)->
    parseInt((cutHex(h)).substring(2,4),16)
hexToB = (h) ->
    parseInt((cutHex(h)).substring(4,6),16)
cutHex = (h) ->
    if h.charAt(0)=="#" then h.substring(1,7) else h

module?.exports = {PythagorasTree: PythagorasTree, Vector:Vector}
