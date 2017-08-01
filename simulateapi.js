var request = require('request');

for(var i=0; i <= 5000; i++) {
	var user_id1 = i;
	var user_id2 = 5000 + i;
	var score = i;

	var string1 = "http://localhost:3000/score/add?user_id=" + user_id1.toString() + "&score=" + score.toString()
	var string2 = "http://localhost:3000/score/add?user_id=" + user_id2.toString() + "&score=" + score.toString()
	console.log(string1)
	request(string1, function (error, response, body) {
    if (!error && response.statusCode == 200) {
        console.log(body) // Print the google web page.
     }
	})
	request(string2, function (error, response, body) {
    if (!error && response.statusCode == 200) {
        console.log(body) // Print the google web page.
     }
	})
}
