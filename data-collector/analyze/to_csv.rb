require 'json'
require 'csv'

CSV.open("data.csv", "wb") do |csv|
  csv << ["dt", "updateTime", "filterObjects", "sum", "mean", "min", "max"]
  
  File.readlines("data.json").each do |x|
    r = JSON.parse(x.strip)
    fo = r["filterObjects"]
    fon = r["filterObjects_numComps"]
    csv << [
      r["dt"],
      r["updateTime"],
      fo["count"],
      fon["sum"],
      fon["mean"],
      fon["min"],
      fon["max"],
    ]
  end

end


