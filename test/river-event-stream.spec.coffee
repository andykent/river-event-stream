es = require('event-stream')
es.query = require('../lib/river-event-stream')

input =  ->
  es.readArray([
    {name: 'Andy',  age: 28}
    {name: 'Sunny', age: 29}
    {name: 'Mark',  age: 22}
  ])

checkOutput = (done, expected) ->
  es.writeArray (err, actual) ->
    actual.should.eql(expected)
    done(err)




describe "River Event Stream", ->

  it "returns a function on require", ->
    es.query.should.be.a('function')


  it "modifies a stream", (done) ->
    es.pipeline(
      input(),
      es.query('SELECT name FROM stream'),
      checkOutput(done, [
        {name:'Andy'}
        {name:'Sunny'}
        {name:'Mark'}
      ])
    )


  it "filters a stream", (done) ->
    es.pipeline(
      input(),
      es.query('SELECT name FROM stream WHERE name = "Andy"'),
      checkOutput(done, [
        {name:'Andy'}
      ])
    )



  it "agreggates a stream", (done) ->
    es.pipeline(
      input(),
      es.query('SELECT sum(age) as totalAge FROM stream'),
      checkOutput(done, [
        {totalAge: 28}
        {totalAge: 57}
        {totalAge: 79}
      ])
    )



  it "emits labelled remove events when requested", (done) ->
    es.pipeline(
      input(),
      es.query('SELECT sum(age) as totalAge FROM stream', {includeRemoves: true}),
      checkOutput(done, [
        ['insert', {totalAge: 28}]
        ['remove', {totalAge: 28}]
        ['insert', {totalAge: 57}]
        ['remove', {totalAge: 57}]
        ['insert', {totalAge: 79}]
      ])
    )

  it "allows naming streams with streamName", (done) ->
    es.pipeline(
      input(),
      es.query('SELECT name FROM people WHERE name = "Andy"', streamName: 'people'),
      checkOutput(done, [
        {name:'Andy'}
      ])
    )