@IsTest
public class CollegeFootballWrapperTest {
	
	static testMethod void testParse() {
		String json = '['+
		'    {'+
		'        \"id\": 401551733,'+
		'        \"season\": 2023,'+
		'        \"week\": 1,'+
		'        \"season_type\": \"postseason\",'+
		'        \"start_date\": \"2023-12-16T16:00:00.000Z\",'+
		'        \"start_time_tbd\": false,'+
		'        \"completed\": false,'+
		'        \"neutral_site\": true,'+
		'        \"conference_game\": false,'+
		'        \"attendance\": null,'+
		'        \"venue_id\": 3654,'+
		'        \"venue\": \"Brooks Stadium\",'+
		'        \"home_id\": 195,'+
		'        \"home_team\": \"Ohio\",'+
		'        \"home_conference\": \"Mid-American\",'+
		'        \"home_division\": \"fbs\",'+
		'        \"home_points\": null,'+
		'        \"home_line_scores\": null,'+
		'        \"home_post_win_prob\": null,'+
		'        \"home_pregame_elo\": 1491,'+
		'        \"home_postgame_elo\": null,'+
		'        \"away_id\": 290,'+
		'        \"away_team\": \"Georgia Southern\",'+
		'        \"away_conference\": \"Sun Belt\",'+
		'        \"away_division\": \"fbs\",'+
		'        \"away_points\": null,'+
		'        \"away_line_scores\": null,'+
		'        \"away_post_win_prob\": null,'+
		'        \"away_pregame_elo\": 1368,'+
		'        \"away_postgame_elo\": null,'+
		'        \"excitement_index\": null,'+
		'        \"highlights\": null,'+
		'        \"notes\": \"Myrtle Beach Bowl\"'+
		'    },'+
		']';
		List<CollegeFootballWrapper> obj = CollegeFootballWrapper.parse(json);
		System.assert(obj != null);
	}
}