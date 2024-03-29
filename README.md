River Event Stream Adapter
==========================

This module forms a bridge to allow River to integrate into an event-stream pipline.

More on River at: https://github.com/andykent/river
More on Event Stream at: https://github.com/dominictarr/event-stream


A Simple Example
----------------

    es = require('event-stream')
    es.query = require('river-event-stream')

    es.pipeline(
      process.openStdin(),
      es.split(),
      es.parse(),
      es.query('SELECT name FROM stream'),
      process.stdout
    )



es.query(sqlString, [options])
------------------------------
This is the only pulic method that is exposed and takes an SQL query string as input along with some optional configuration options.

The options are...

* `includeInserts`: true by default, setting to false will mean insert events aren't outputted.
* `includeRemoves`: false by default, setting to true will emit remove events. These can be useful when doing aggregations.
* `streamName`: 'stream' by default, you can pass any valid SQL identifier to be used to identify your stream in the query e.g. 'FROM myStream'
* `multiplexed`: false by default, setting multiplexed to true allows you to run a query that joins on mutiple streams. When this option is true the input stream should take the form of tuples, e.g. `['myStream', {data}], ['myOtherStream', {data}], ['myStream', {data}]`

Note: When `includeInserts` and `includeRemoves` are both true the stream emits tuples so you can differentiate between inserts and removes. They look like this... `['insert', {data}]` and `['remove', {data}]`