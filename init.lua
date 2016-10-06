profile_system = {
saved_entries = {},
saved_othernames = {},
saved_first_played = {},
saved_age = {},
saved_mood = {},
saved_rating = {}
}

minetest.register_chatcommand("profile_edit", {
  func = function(name, param)
    local text_area_content = profile_system.saved_entries[name] or ""
    minetest.show_formspec(name, "profile_system:profile_edit",
      "size[7,7]" ..
      "label[0,0;Fill in the form to update your profile.]" ..
      "label[0,5.5;".. minetest.formspec_escape(text_area_content) .."]" ..
      "field[.5,1;3,.75;year_played;First year playing Minetest:; ]" ..
      "field[.5,2;3,.75;other_names;Other game names:; ]" ..
      "textarea[.5,3;5,3;short_description;Short description about yourself:; ]" ..
      "label[3.5,.5;Choose your mood:]" ..
      "dropdown[3.5,1;3;mood;Happy,Mad,Sad; ]" ..
      "button_exit[0,6.5;2,1;exit;Submit]")
  end
})

function save_table_data()
  local data = profile_system
  local f, err = io.open(minetest.get_worldpath() .. "/profile_formtable", "w")
  if err then
    return err
  end
  f:write(minetest.serialize(data))
  f:close()
end

function read_table_data()
  local f, err = io.open(minetest.get_worldpath() .. "/profile_formtable", "r")
  local data = minetest.deserialize(f:read("*a"))
  f:close()
    return data
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "profile_system:profile_edit" then
    if fields.year_played <= "2009" then
      minetest_age = "Invalid"
    elseif fields.year_played == "2010" then
      minetest_age = 6
    elseif fields.year_played == "2011" then
      minetest_age = 5
    elseif fields.year_played == "2012" then
      minetest_age = 4
    elseif fields.year_played == "2013" then
      minetest_age = 3
    elseif fields.year_played == "2014" then
      minetest_age = 2
    elseif fields.year_played == "2015" then
      minetest_age = 1
    elseif fields.year_played == "2016" then
      minetest_age = 0
    elseif fields.year_played >= "2017" then
      minetest_age = "Invalid"
    end
    if fields.mood == "Happy" then
      profile_system.saved_mood[player:get_player_name()] = "happy.png"
    elseif fields.mood == "Sad" then
      profile_system.saved_mood[player:get_player_name()] = "sad.png"
    elseif fields.mood == "Mad" then
      profile_system.saved_mood[player:get_player_name()] = "mad.png"
    end
    if fields.year_played <= "2009" then
      profile_system.saved_first_played[player:get_player_name()] = "Invalid"
    elseif fields.year_played >= "2017" then
      profile_system.saved_first_played[player:get_player_name()] = "Invalid"
    else
      profile_system.saved_first_played[player:get_player_name()] = fields.year_played
    end
    profile_system.saved_entries[player:get_player_name()] = fields.short_description
    profile_system.saved_othernames[player:get_player_name()] = fields.other_names
    profile_system.saved_age[player:get_player_name()] = minetest_age
    save_table_data()
  end
end)

profile_system = read_table_data()

minetest.register_chatcommand("my_profile", {
     func = function(name, param)
          profile_system = read_table_data()
          if profile_system.saved_mood[name] == "" then
               profile_system.saved_mood[name] = "N/A"
          elseif profile_system.saved_first_played[name] == "" then
               profile_system.saved_first_played[name] = "N/A"
          elseif profile_system.saved_age[name] == "" then
               profile_system.saved_age[name] = "N/A"
          elseif profile_system.saved_othernames[name] == "" then
               profile_system.saved_othernames[name] = "N/A"
          elseif profile_system.saved_entries[name] == "" then
               profile_system.saved_entries[name] = "N/A"
          end
          minetest.show_formspec(name, "profile_system:self_profile",
               "size[7,7]" ..
               "label[3,0;Profile]" ..
               "image[2.5,1;2,2;"..profile_system.saved_mood[name].."]" ..
               "label[1,3;First played Minetest in: "..profile_system.saved_first_played[name].."]" ..
               "label[1,3.5;Minetest age: "..profile_system.saved_age[name].."]" ..
               "label[1,4;Other game names: "..profile_system.saved_othernames[name].."]" ..
               "label[1,4.5;Player Description: "..profile_system.saved_entries[name].."]" ..
               "button[3,6.5;2,1;pic_change;Change Profile Picture]" ..
               "button_exit[0,6.5;2,1;exit;Close]")
     end
})

function profile_pic_change(name, param)
     minetest.show_formspec(name, "profile_system:profile_picture_change",
          "size[7,7]" ..
          "image_button[0,0;1,1;pic1.png;pic1; ]" ..
          "image_button[1,0;1,1;pic2.png;pic2; ]" ..
          "image_button[2,0;1,1;pic3.png;pic3; ]" ..
          "button_exit[0,6.5;2,1;exit;Close]")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
     if formname == "profile_system:self_profile" then
          if fields.pic_change then
               profile_pic_change()
          end
     end
end)

players = {
playernames = {minetest.get_dir_list(minetest.get_worldpath().."/players", false)}
}

function get_player_list()
     local stuff = players
     local f, err = io.open(minetest.get_worldpath() .. "/player_profiles", "w")
     if err then
       return err
     end
     f:write(minetest.serialize(stuff))
     f:close()
end

function read_stuff()
     local file = io.open(minetest.get_worldpath() .. "/player_profiles", "r")
     local arr = {}
     for line in file:lines() do
        table.insert (arr, line);
     end
     return arr
end

function value_get(arr, val)
     players = read_stuff()
     local arr = {}
     for index, value in ipairs(arr) do
         if value == val then
             return true
         end
     end
     return false
end

minetest.register_chatcommand("profile", {
     param = "<name>",
     func = function(name, param, val)
          profile_system = read_table_data()
          if profile_system.saved_mood[param] == "" then
               profile_system.saved_mood[param] = "N/A"
          elseif profile_system.saved_first_played[param] == "" then
               profile_system.saved_first_played[param] = "N/A"
          elseif profile_system.saved_age[param] == "" then
               profile_system.saved_age[param] = "N/A"
          elseif profile_system.saved_othernames[param] == "" then
               profile_system.saved_othernames[param] = "N/A"
          elseif profile_system.saved_entries[param] == "" then
               profile_system.saved_entries[param] = "N/A"
          end
          get_player_list()
          players = read_stuff()
          local arr = {}
          if value_get(arr, param) then
               minetest.show_formspec(name, "profile_system:player_profile",
                    "size[7,7]" ..
                    "label[3,0;".. param .."]" ..
                    "image[2.5,1;2,2;"..profile_system.saved_mood[param].."]" ..
                    "label[1,3;First played Minetest in: "..profile_system.saved_first_played[param].."]" ..
                    "label[1,3.5;Minetest age: "..profile_system.saved_age[param].."]" ..
                    "label[1,4;Other game names: "..profile_system.saved_othernames[param].."]" ..
                    "label[1,4.5;Player Description: "..profile_system.saved_entries[param].."]" ..
                    "button_exit[0,6.5;2,1;exit;Close]")
          else
               minetest.chat_send_player(name, "Player ".. param .." does not exist or has not created a profile.")
          end
     end
})


minetest.register_chatcommand("rate_server", {
     func = function(name, param)
          minetest.show_formspec(name, "profile_system:server_rate_form",
               "size[7,7]" ..
               "label[0,0;Rate the server (0-5):]" ..
               "dropdown[0,1;2;server_rating;0,1,2,3,4,5; ]" ..
               "label[0,2;Current overall server rating:]" ..
               "button_exit[0,6.5;2,1;exit;Submit]")
     end
})

local average, n = 0, 0
minetest.register_on_player_receive_fields(function(value, player, formname, fields)
     if formname == "profile_system:server_rate_form" then
          profile_system.saved_rating[player:get_player_name()] = fields.server_rating
          save_table_data()
          profile_system = read_table_data()
          average = average * n
          average = average + value
          n = n + 1
          average = average / n
     end
end)
