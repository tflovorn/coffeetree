tree = require "../lib/tree"

# for debugging --
# console.log(str) prints str to console

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

# known is [xMin, yMin, xMax, yMax]
checkHasBounds = (bounds, known) ->
    minCorrect = bounds.min.x == known[0] and bounds.min.y == known[1]
    maxCorrect = bounds.max.x == known[2] and bounds.max.y == known[3]
    minCorrect and maxCorrect

checkWithinBounds = (bounds, known) ->
    minWithin = bounds.min.x >= known[0] and bounds.min.y >= known[1]
    maxWithin = bounds.max.x <= known[2] and bounds.max.y <= known[3]
    minWithin and maxWithin
