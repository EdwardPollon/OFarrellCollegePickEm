public class CollegeFootballWrapper {

	public Integer id;
	public Integer season;
	public Integer week;
	public String season_type;
	public String start_date;
	public Boolean start_time_tbd;
	public Boolean completed;
	public Boolean neutral_site;
	public Boolean conference_game;
	public Integer attendance;
	public Integer venue_id;
	public String venue;
	public Integer home_id;
	public String home_team;
	public String home_conference;
	public String home_division;
	public Integer home_points;
	public List<Integer> home_line_scores;
	public String home_post_win_prob;
	public Integer home_pregame_elo;
	public Integer home_postgame_elo;
	public Integer away_id;
	public String away_team;
	public String away_conference;
	public String away_division;
	public Integer away_points;
	public List<Integer> away_line_scores;
	public String away_post_win_prob;
	public Integer away_pregame_elo;
	public Integer away_postgame_elo;
	public String excitement_index;
	public String highlights;
	public String notes;

	
	public static List<CollegeFootballWrapper> parse(String json) {
		return (List<CollegeFootballWrapper>) System.JSON.deserialize(json, List<CollegeFootballWrapper>.class);
	}
}