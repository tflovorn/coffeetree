tree = require "../lib/tree"

describe 'PythagorasTree', ->

    it 'lowest order tree should have only a root', ->
        tinyTree = new tree.PythagorasTree(1.0, Math.PI / 4, 0)
        expect(tinyTree.root).toBeDefined()
        expect(tinyTree.root).not.toBeNull()
        expect(tinyTree.root.left).toBeNull()
        expect(tinyTree.root.right).toBeNull()
