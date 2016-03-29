fs = require 'fs'
csvParse = require 'csv-parse'
jsonfile = require 'jsonfile'

infile=__dirname+'/world_map.csv'
outfile=__dirname+'/../../../../build/data/world_map.json'

convertCsvData = (data) ->
  for row,r in data
    for cell,c in row
      if cell == ''
        data[r][c] = null
      else
        data[r][c] = cell

getInGrid1 = (data,col,row) -> data[row-1][col-1]
        
opts={}
mapDef = {}
handle = csvParse opts, (err,data) ->
  convertCsvData(data)
  numRows = data.length
  numCols = data[0].length
  mapDef.data = data
  mapDef.rows = numRows
  mapDef.cols = numCols

  jsonfile.writeFile outfile, mapDef, {spaces: 2}, (err) ->
    if err?
      console.error "ERRNO!",err
    # else
    #   console.log "Ok: wrote out.json"

str = fs.createReadStream(infile)
str.pipe(handle)
