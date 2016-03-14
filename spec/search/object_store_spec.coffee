# Finder = require '../../src/javascript/search/immutable_object_finder'
Immutable = require 'immutable'
ExpectHelpers = require '../helpers/expect_helpers'
expectIs = ExpectHelpers.expectIs

ObjectStore = require '../../src/javascript/search/object_store'

util = require 'util'

chai = require('chai')
expect = chai.expect
assert = chai.assert

imm = Immutable.fromJS
immset = (xs...) -> Immutable.Set(xs)

padThai = imm dishId: 'i1', dish: 'Pad Thai', base: 'noodles'
houseSpecial = imm dishId: 'i2', dish: 'Curry fried rice', base: 'rice'
curryPadThai = imm dishId: 'i3', dish: 'Basil Cury', base: 'rice'
pcn = imm dishId: 'i4', dish: 'Peanut Curry Noodle', base: 'noodles'

dishList = imm [ padThai, houseSpecial, curryPadThai, pcn ]

books = imm [
  { bookId: 'b1', cat: 'fiction', genre: 'scifi', title: 'Foundation' }
  { bookId: 'b2', cat: 'nonfiction', genre: 'selfhelp', title: 'Crucial Conversations' }
  { bookId: 'b3', cat: 'fiction', genre: 'fantasy', title: 'The Wheel of Time' }
  { bookId: 'b4', cat: 'fiction', genre: 'scifi', title: 'Time Enough for Love' }
]
mappedBooks = ObjectStore.mappedBy(books,'bookId')
book1 = mappedBooks.get('b1')
book4 = mappedBooks.get('b4')

describe "ObjectStore", ->
  describe "data transformation fns", ->
    describe "mappedBy", ->
      it "converts a list of objects into a map, keyed by the indicated key", ->
        m = ObjectStore.mappedBy(dishList, 'dishId')
        expectIs m, imm(
          i1: padThai
          i2: houseSpecial
          i3: curryPadThai
          i4: pcn
        )

      it "returns empty map for empty list", ->
        m = ObjectStore.mappedBy(imm([]), 'wat')
        expectIs m, imm({})

    describe "indexObjects", ->
      it "given objects and a prop names, group the objects' identKeys by the given prop name", ->
        idx = ObjectStore.indexObjects(dishList, ['base'], 'dishId')
        expectIs idx, imm(
          rice: immset('i2','i3')
          noodles: immset('i1','i4')
        )

      it "given objects and a list of n prop names, return an n-ary keyed map of key-paths to their identifier keys", ->
        idx = ObjectStore.indexObjects(books, ['cat','genre'], 'bookId')
        expectIs idx, imm(
          fiction:
            scifi: immset('b1','b4')
            fantasy: immset('b3')
          nonfiction:
            selfhelp: immset('b2')
        )

  describe "store manipulation fns", ->
    store = null
    beforeEach ->
      store = ObjectStore.create('bookId')

    describe "addObject() and getObject()", ->
      it "can store and retrieve objects according to the dataKey", ->
        store = ObjectStore.addObject(store, books.get(0))
        expectIs ObjectStore.getObject(store, 'b1'), books.get(0)

      it "returns null when requested object isn't there", ->
        expect(ObjectStore.getObject(store, 'NOOO')).to.be.null
        expect(ObjectStore.getObject(store, '')).to.be.null
        expect(ObjectStore.getObject(store, null)).to.be.null


    describe "addIndex(), getIndexedObjectIds() and getIndexedObjects()", ->
      it "can add multiple objects and index them and retrieve by indexed search", ->
        store = ObjectStore.addIndex(store, imm(['genre']))
        store = ObjectStore.addObjects(store, books)
        scifiBookIds = ObjectStore.getIndexedObjectIds(store, imm(['genre']), imm(['scifi']))
        expectIs scifiBookIds, immset('b1', 'b4')


        store = ObjectStore.addIndex(store, imm(['cat','genre']))
        helps = ObjectStore.getIndexedObjectIds(store, imm(['cat','genre']), imm(['nonfiction','selfhelp']))
        expectIs helps, immset('b2')
        store = ObjectStore.addObject(store, imm { bookId: 'b05', cat: 'nonfiction', genre: 'selfhelp', title: '7 Habits of Highly Effective People' })
        helps = ObjectStore.getIndexedObjectIds(store, imm(['cat','genre']), imm(['nonfiction','selfhelp']))
        expectIs helps, immset('b2','b05')

      it "can retrieve actual objects", ->
        store = ObjectStore.addIndex(store, imm(['genre']))
        store = ObjectStore.addObjects(store, books)

        scifiBooks = ObjectStore.getIndexedObjects(store, imm(['genre']), imm(['scifi']))
        expectIs scifiBooks, immset(book1, book4)

      it "returns empty Set when requested index isn't there", ->
        res = ObjectStore.getIndexedObjectIds(store, imm(['something','wicked']), imm(['this way','comes']))
        expectIs res, immset()

        res = ObjectStore.getIndexedObjectIds(store, imm([]), imm(['this way','comes']))
        expectIs res, immset()

        res = ObjectStore.getIndexedObjectIds(store, null, imm(['this way','comes']))
        expectIs res, immset()

        res = ObjectStore.getIndexedObjects(store, null, imm(['this way','comes']))
        expectIs res, immset()

    describe "hasIndex()", ->
      it 'tells you if an index is present or not', ->
        index1 = imm(['genre'])
        index2 = imm(['cat','genre'])

        expect(ObjectStore.hasIndex(store, index1)).to.equal(false)
        store = ObjectStore.addIndex(store, index1)
        expect(ObjectStore.hasIndex(store, index1)).to.equal(true)

        expect(ObjectStore.hasIndex(store, index2)).to.equal(false)
        store = ObjectStore.addIndex(store, index2)
        expect(ObjectStore.hasIndex(store, index2)).to.equal(true)
        expect(ObjectStore.hasIndex(store, index1)).to.equal(true)

        expect(ObjectStore.hasIndex(store, [])).to.equal(false)
        expect(ObjectStore.hasIndex(store, null)).to.equal(false)

    describe "getIndices()", ->
      it "returns a sequence of index definers", ->
        index1 = imm(['genre'])
        index2 = imm(['cat','genre'])
        store = ObjectStore.addIndex(store, index1)
        store = ObjectStore.addIndex(store, index2)
        indices = ObjectStore.getIndices(store)
        expectIs indices.toList(), imm([ ['genre'], ['cat','genre'] ])

      it "returns empty List when no indexes are present", ->
        indices = ObjectStore.getIndices(store)
        expectIs indices.toList(), imm([])

    describe "bestIndexForKeys()", ->
      catIndex = imm(['cat'])
      catGenreIndex = imm(['cat','genre'])

      beforeEach ->
        store = ObjectStore.addIndex(store, imm(['other']))
        store = ObjectStore.addIndex(store, catIndex)
        store = ObjectStore.addIndex(store, catGenreIndex)

      it "finds which indices in a store may be used for the given match configuration", ->
        match = imm
          genre: 'scifi'
          cat: 'fiction'
          dude: "dave"

        keys = match.keySeq().toSet()
        index = ObjectStore.bestIndexForKeys(store,keys)
        expectIs index, imm(['cat','genre'])

        keys2 = match.delete('genre').keySeq().toSet()
        index2 = ObjectStore.bestIndexForKeys(store,keys2)
        expectIs index2, imm(['cat'])

        keys3 = match.delete('genre').delete('cat').keySeq().toSet()
        index3 = ObjectStore.bestIndexForKeys(store,keys3)
        expect(index3).to.be.null


  describe "ObjectStore.Wrapper", ->
    wrapper = null
    beforeEach ->
      wrapper = ObjectStore.createWrapper('bookId')

    it "can store and retrieve objects according to the dataKey", ->
      wrapper.add(books.get(0))
      expectIs wrapper.get('b1'), books.get(0)

    it "can add multiple objects and index them and retrieve by indexed search", ->
      wrapper.addIndex(imm(['genre']))
      wrapper.addAll(books)
      scifiBookIds = wrapper.getIndexedObjectIds(imm(['genre']), imm(['scifi']))
      expectIs scifiBookIds, immset('b1', 'b4')

      scifiBooks = wrapper.getIndexedObjects(imm(['genre']), imm(['scifi']))
      expectIs scifiBooks, immset(book1, book4)

      wrapper.addIndex(imm(['cat','genre']))
      helps = wrapper.getIndexedObjectIds(imm(['cat','genre']), imm(['nonfiction','selfhelp']))
      expectIs helps, immset('b2')

      store = wrapper.add(imm { bookId: 'b05', cat: 'nonfiction', genre: 'selfhelp', title: '7 Habits of Highly Effective People' })
      helps = wrapper.getIndexedObjectIds(imm(['cat','genre']), imm(['nonfiction','selfhelp']))
      expectIs helps, immset('b2','b05')

      expectIs wrapper.getIndices(), imm([['genre'],['cat','genre']])

    it "can indicate presence of an index", ->
      expect(wrapper.hasIndex(imm(['genre']))).to.equal(false)
      wrapper.addIndex(imm(['genre']))
      expect(wrapper.hasIndex(imm(['genre']))).to.equal(true)


# [
#   {
#     as: 'bullet'
#     match:
#       type: 'bullet'
#   }
#   {
#     as: 'hit_box'
#     match:
#       type: 'hit_box'
#       eid: ['bullet','eid']
#   }
#   {
#     as: 'animation'
#     match:
#       type: 'animation'
#       eid: {matching: ['bullet','eid']}
#   }
# ]
