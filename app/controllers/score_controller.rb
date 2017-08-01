class ScoreController < ApplicationController
  
  $score_bucket = Hash.new
	for i in 0..5000
		$score_bucket[i] = Score.new
	end 
  
	$user_map = Hash.new


  def new
  end

  def add
  	user_id = params["user_id"].to_i
  	score = params["score"].to_i
  	if $user_map[user_id].nil?
  		node = Node.new
  		node.user_id = user_id
  		node.score = score
  		add_to_score_map(node, score)
  		$user_map[user_id] = node
  	else	
  		node = $user_map[user_id]
  		prev_score = node.score
  		new_score = prev_score + score
			delete_from_score_map(node, prev_score)
			add_to_score_map(node, new_score)
			node.score = new_score
  	end
  end

  def delete_from_score_map(node, score)
  	count = $score_bucket[score].count
  	if count == 1
  		$score_bucket[score].first = nil
  		$score_bucket[score].last = nil
  		$score_bucket[score].count = 0
  	else
  		prev_node = node.prev
  		next_node = node.next
  		prev_node.next = next_node if prev_node.present?
  		next_node.prev = prev_node if next_node.present?
  		$score_bucket[score].first = next_node if $score_bucket[score].first.user_id == node.user_id
  		$score_bucket[score].last = prev_node if $score_bucket[score].last.user_id == node.user_id
  		$score_bucket[score].count = count - 1
  	end
  	node.prev = nil
  	node.next = nil
  end

  def add_to_score_map(node, score)
  	count = $score_bucket[score].count
  	if count == 0
  		$score_bucket[score].first = node
  		$score_bucket[score].last = node
  		$score_bucket[score].count = 1
  	else
  		$score_bucket[score].last.next = node
  		node.prev = $score_bucket[score].last
  		$score_bucket[score].last = node
  		$score_bucket[score].count = count + 1
  	end
  end

  def leaderboard
  	count = params["count"].to_i
  	@list = down_neighbours(5000, count)
  end

  def get_score_list(score, count, top)
  	list_size = $score_bucket[score].count < count ? $score_bucket[score].count : count
  	score_list = []
  	return [] if list_size == 0
  	node = top == true ? $score_bucket[score].first : $score_bucket[score].last
  	score_list.push(node)
  	for i in 2..list_size
  		node = top == true ? node.next : node.prev
  		score_list.push(node)
  	end
  	return score_list
  end

  def neighbour
  	n1 = params["n1"].to_i
  	n2 = params["n2"].to_i
  	user_id = params["user_id"].to_i
  	@list_up = []
  	@list_down = []
  	node = $user_map[user_id]
  	return if node == nil
  	
  	while n1 > 0 && node!=nil
  		node = node.next
  		@list_up.push(node) if node != nil
  		n1 = n1 - 1
  		n1 = n1 + 1 if node == nil
  	end
  	@list_up = @list_up + up_neighbours($user_map[user_id].score + 1, n1)
  	
  	node = $user_map[user_id]
  	while n2 > 0 && node!=nil
  		node = node.prev
  		@list_down.push(node) if node != nil
  		n2 = n2 - 1
  		n2 = n2 + 1 if node == nil
  	end
  	
  	@list_up.reverse!
  	@list_down = @list_down + down_neighbours($user_map[user_id].score - 1, n2)
  	@user_node = $user_map[user_id]
  end

  def down_neighbours(score, count)
  	down_list = []
  	while count >=0 && score>=0
  		score_list = get_score_list(score, count, true)
  		count = count - score_list.size
  		down_list = down_list + score_list
  		score = score - 1
  	end
  	down_list
  end

  def up_neighbours(score, count)
  	up_list = []
  	while count >=0 && score<=5000
  		score_list = get_score_list(score, count, false)
  		count = count - score_list.size
  		up_list = up_list + score_list
  		score = score + 1
  	end
  	up_list
  end


end
