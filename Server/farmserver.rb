  require 'webrick'
  require 'builder'
  require 'rubygems'
  require 'nokogiri'
  require 'pg'

  class PlantInBase
    def id
      @id
    end
    def x
      @x
    end
    def y
      @y
    end
    def state
      @state
    end
    def planttype
      @planttype
    end
    def initialize(id, x, y, state, planttype)
      @id = id
      @x = x
      @y = y
      @state = state
      @planttype = planttype
    end
  end

  class PersistAnswers < WEBrick::HTTPServlet::AbstractServlet
    def do_POST(request, response)
      xml_string = request.body
      xml_doc = Nokogiri::XML(xml_string)
      param_act = xml_doc.css("field act").first.text
      param_x = xml_doc.css("field x").first.text
      param_y = xml_doc.css("field y").first.text
      param_id = xml_doc.css("field id").first.text
      puts "act:"+ param_act + "; x:" + param_x + "; y:" + param_y + "; id:" + param_id

      conn = PGconn.connect("localhost", 5432, '', '', "farm", "postgres", "")
      res  = conn.exec('SELECT id, x, y, state, planttype FROM "Field";')
      plantsinbase = Array.new
      maxid = 0
      existsinbase = false
      res.each do |row|
          plant = PlantInBase.new(row['id'], row['x'], row['y'], row['state'], row['planttype'])
          if (row['id'].to_i > maxid)
            maxid = row['id'].to_i
          end
          if (param_act != "" && row['x'] == param_x && row['y'] == param_y)
            existsinbase = true
          end
          plantsinbase << plant
      end
      maxid += 1

      case param_act
        when "clover"
          #insert
          if (!existsinbase)
            newplant = PlantInBase.new(maxid.to_s, param_x, param_y, 1, param_act)
            insertplant(conn, newplant)
          end
        when "sunflower"
          #insert
          if (!existsinbase)
            newplant = PlantInBase.new(maxid.to_s.to_s, param_x, param_y, 1, param_act)
            insertplant(conn, newplant)
          end
        when "potato"
          #insert
          if (!existsinbase)
            newplant = PlantInBase.new(maxid.to_s, param_x, param_y, 1, param_act)
            insertplant(conn, newplant)
          end
        when "harvest"
          #delete
          deleteplant(conn, param_id)
         when "move"
           #move plant
           updateplace(conn,param_x,param_y,param_id)
        when "turn"
          #grow
          plantsinbase.each do |plant|
            newstate = plant.state.to_i+1
            if (newstate > 5)
              newstate = 5
            end
            updatestate(conn, newstate, plant.id)
          end
        else
          #
      end

	#так не делать
      def insertplant(conn,plantin)
        res = conn.exec('INSERT INTO "Field"(id, x, y, state, planttype) VALUES ('+plantin.id+', '+plantin.x+', '+plantin.y+', '+plantin.state.to_s+', \''+plantin.planttype+'\');')
      end

      def deleteplant(conn,id)
        res = conn.exec('DELETE FROM "Field" WHERE id = '+ id +';')
      end

      def updateplace(conn,x,y,id)
        res = conn.exec('UPDATE "Field" SET x='+x+', y ='+y+' WHERE id = '+ id +';')
      end

      def updatestate(conn,state,id)
        res = conn.exec('UPDATE "Field" SET state='+state.to_s+' WHERE id = '+id+';')
      end


      res  = conn.exec('SELECT id, x, y, state, planttype FROM "Field";')
      plantsinbase = Array.new
      res.each do |row|
          plant = PlantInBase.new(row['id'], row['x'], row['y'], row['state'], row['planttype'])
          plantsinbase << plant
      end
	#так не делать


      response['Content-Type'] = 'text/html'
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.country do
         xml.field( :zero_x => 0, :zero_y => 0, :size_x => 60, :size_y => 60 ) do
             plantsinbase.each do |planttoclient|
                case planttoclient.planttype
                  when "clover"
                    xml.clover(:id => planttoclient.id, :x => planttoclient.x, :y => planttoclient.y, :process_end => planttoclient.state)
                  when "sunflower"
                    xml.sunflower(:id => planttoclient.id, :x => planttoclient.x, :y => planttoclient.y, :process_end => planttoclient.state)
                  when "potato"
                    xml.potato(:id => planttoclient.id, :x => planttoclient.x, :y => planttoclient.y, :process_end => planttoclient.state)
                  else
                    #
                end
             end
             #xml.clover(:id => 2777, :x => 0, :y => 0, :process_end => 4)
             #xml.sunflower(:id => 2778, :x => 0, :y => 5, :process_end => 4)
             #xml.potato(:id => 2779, :x => 0, :y => 10, :process_end => 4)
             #xml.clover(:id => 2780, :x => 5, :y => 0, :process_end => 2)
             #xml.sunflower(:id => 2781, :x => 5, :y => 5, :process_end => 2)
             #xml.potato(:id => 2782, :x => 5, :y => 10, :process_end => 2)
         end
      end
      response.body = xml.target!
    end
  end

  server = WEBrick::HTTPServer.new(:Port=>1234, :DocumentRoot => "")
  server.mount "/field", PersistAnswers
  trap("INT"){ server.shutdown }
  server.start

  # TO DO:
  # РїСЂРёРєСЂСѓС‚РёС‚СЊ С„СЂРµР№РјРІРѕСЂРє sprouts (http://projectsprouts.org/)