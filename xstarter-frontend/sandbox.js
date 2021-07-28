
function getInfoForEachRow(row_num, entry) {
  let empty_string = ''
  row_num += 1
  console.log('row num', row_num, entry)
  // name
  let name = document.querySelector(`#entries-table > tbody > tr:nth-child(${row_num}) > td:nth-child(1) > div > a > span.d-none.d-md-block`).innerText
  empty_string += name.trim()

  // sport
  let sport = document.querySelector(`#entries-table > tbody > tr:nth-child(${row_num}) > td.sorting_2 > a`).innerText
  empty_string += ";" + sport.trim()
  // gender

  let gender = document.querySelector(`#entries-table > tbody > tr:nth-child(${row_num}) > td:nth-child(4)`).innerText
  empty_string += ";" + gender.trim()

  return empty_string + "\n"
}

function runScript() {
  let csvValue = "country;sport;gender\n "
  let entry = 0

  while (entry < 743) {
    try {
      csvValue +=  getInfoForEachRow(entry % 20, entry) // since each pagination is 20 rows and row number in queryselector starts at 1
      entry++
      if (entry % 20 === 19) {
        document.querySelector('#entries-table_next > a').click()
      }
    } catch (e) {
      console.log('done')
      break
    }

  }

  console.log(csvValue)
  return csvValue

}




