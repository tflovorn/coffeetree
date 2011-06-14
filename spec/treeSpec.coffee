tree = require "../lib/tree"

# for debugging --
# console.log(str) prints str to console

describe 'Vector', ->
    it 'dot product known values', ->
        v = new tree.Vector(3.0, 3.0)
        expect(v.normSquared()).toEqual(18.0)
        u = new tree.Vector(1.0, 1.0)
        expect(v.dot(u)).toEqual(6.0)

describe 'PythagorasTree', ->

    it 'lowest order tree should have only a root node', ->
        tinyTree = new tree.PythagorasTree(1.0, Math.PI / 4, 0)
        expect(tinyTree.root).toBeDefined()
        expect(tinyTree.root).not.toBeNull()
        expect(tinyTree.root.left).toBeNull()
        expect(tinyTree.root.right).toBeNull()

    it 'lowest order tree should be bounded by the root node', ->
        tinyTree = new tree.PythagorasTree(1.0, Math.PI / 4, 0)
        bounds = tinyTree.bounds()
        known = [0.0, 0.0, 1.0, 1.0]
        expect(checkHasBounds(bounds, known)).toBeTruthy()

    it '45 degree first-order tree should have known bounds', ->
        firstTree = new tree.PythagorasTree(1.0, Math.PI / 4, 1)
        bounds = firstTree.bounds()
        known = [-0.5, 0.0, 1.5, 2.0]
        expect(checkHasBounds(bounds, known)).toBeTruthy()

    it 'high-order 45 degree tree should fit within 6x4 box', ->
        megaTree = new tree.PythagorasTree(1.0, Math.PI / 4, 12)
        bounds = megaTree.bounds()
        known = [-2.5, 0.0, 3.5, 4.0]
        expect(checkWithinBounds(bounds, known)).toBeTruthy()

    it 'check known values of pixelHit for 45 degree first-order tree', ->
        firstTree = new tree.PythagorasTree(1.0, Math.PI / 4, 1)
        bounds = firstTree.bounds()
        pixelNums = [8, 8]  # 8x8 pixel grid
        rootHits = [[2,4],[5,4],[3,5],[2,7],[5,7]]  # 4x4 aligned with pixels
        rootMiss = [[1,1],[5,1],[0,4],[7,4]]
        leftHits = [[1,1],[2,1],[1,2],[2,2]]        # 2x2 45deg to pixels
        leftMiss = [[2,4],[3,5],[5,1],[7,7]]
        rightHits = [[5,1],[6,1],[5,2],[6,2]]       # same as left
        rightMiss = [[0, 0], [2,2], [5,5], [4,7]]
        expect(checkPixels(firstTree.root, bounds, pixelNums, rootHits, rootMiss)).toBeTruthy()
        expect(checkPixels(firstTree.root.left, bounds, pixelNums, leftHits, leftMiss)).toBeTruthy()
        expect(checkPixels(firstTree.root.right, bounds, pixelNums, rightHits, rightMiss)).toBeTruthy()

    it 'allPossiblePixels has known values on 45 degree first-order tree', ->
        firstTree = new tree.PythagorasTree(1.0, Math.PI / 4, 1)
        bounds = firstTree.bounds()
        pixelNums = [8, 8]  # 8x8 pixel grid
        pixels = firstTree.root.left.allPossiblePixels(bounds, pixelNums)
        known = []
        for nx in [0..3]
            for ny in [0..3]
                known.push([nx, ny])
        expect(pixels).toEqual(known)

# known is [xMin, yMin, xMax, yMax]
checkHasBounds = (bounds, known) ->
    minCorrect = bounds.min.x == known[0] and bounds.min.y == known[1]
    maxCorrect = bounds.max.x == known[2] and bounds.max.y == known[3]
    minCorrect and maxCorrect

checkWithinBounds = (bounds, known) ->
    minWithin = bounds.min.x >= known[0] and bounds.min.y >= known[1]
    maxWithin = bounds.max.x <= known[2] and bounds.max.y <= known[3]
    minWithin and maxWithin

# check if all pixels in hits do hit node and all in miss don't hit done
checkPixels = (node, bounds, pixelNums, hits, miss) ->
    for pixel in hits #when !node.pixelHit(bounds, pixelNums, pixel)
        didHit = node.pixelHit(bounds, pixelNums, pixel)
        if !didHit
            console.log(pixel, didHit)
            return false
    for pixel in miss #when node.pixelHit(bounds, pixelNums, pixel)
        didHit = node.pixelHit(bounds, pixelNums, pixel)
        if didHit
            console.log(pixel, didHit)
            return false
    true
