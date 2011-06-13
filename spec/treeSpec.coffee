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
        expect(bounds[0].x).toEqual(0.0)
        expect(bounds[0].y).toEqual(0.0)
        expect(bounds[1].x).toEqual(1.0)
        expect(bounds[1].y).toEqual(1.0)

    it 'first-order tree should have known bounds', ->
        firstTree = new tree.PythagorasTree(1.0, Math.PI / 4, 1)
        bounds = firstTree.bounds()
        expect(bounds[0].x).toEqual(-0.5)
        expect(bounds[0].y).toEqual(0.0)
        expect(bounds[1].x).toEqual(1.5)
        expect(bounds[1].y).toEqual(2.0)
