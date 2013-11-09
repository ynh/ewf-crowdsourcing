note
	description: "Summary description for {DETAIL_PAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DETAIL_PAGE

inherit

	BASE_PAGE
		redefine
			initialize_controls,
			make
		end

create
	make

feature {NONE}

	make (db: SQLITE_DATABASE; req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			int_id: INTEGER_64
		do
			database := db
			if attached req.path_parameter ("project_id") as a_id then
				int_id := a_id.as_string.value.to_integer_64
			end
			load_data (int_id)
			make_wsf_page (req, res)
		end

	load_data (id: INTEGER_64)
		local
			project_query: SQL_QUERY [SQL_ENTITY]
			media_query: SQL_QUERY [SQL_ENTITY]
		do
			create project_query.make ("projects")
			project_query.set_fields (<<["title"], ["description"]>>)
			project_query.set_where ("id = " + id.out)
			project := project_query.first (database)

				--Load Media
			create media_query.make ("media")
			media_query.set_fields (<<["tag"], ["url"]>>)
			media_query.set_where ("project_id = " + id.out + " and tag != 'thumbnail' ")
			media := media_query.run (database)
		end

feature -- Initialization

	initialize_controls
		do
			Precursor
			main_control.add_column (8)
			main_control.add_column (4)
			navbar.set_active (2)
			create slider.make
			if attached project as a_project then
				main_control.add_control (1, create {WSF_BASIC_CONTROL}.make_with_body ("h3", "", a_project.get_string ("title")))
				main_control.add_control (1, slider)
				main_control.add_control (1, create {WSF_BASIC_CONTROL}.make_with_body ("p", "", a_project.get_string ("description")))
			end
			if attached media as a_media then
				across
					a_media as m
				loop
					slider.add_image (m.item.get_string ("url"), "")
				end
			end
		end

feature -- Implementation

	process
		do
		end

feature -- Properties

	project: detachable SQL_ENTITY

	media: detachable LIST [SQL_ENTITY]

	slider: WSF_SLIDER_CONTROL

end
