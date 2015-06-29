class Crawler < ActiveRecord::Base


	def self.crawl

		a = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
		}

		data = {
			"valorcmbEstado" => "11",
			"valorcmbModalidad" => "",
			"valorcmbNormativa" => "",
			"valorcmbRubro" => "{VALORMNURUBRO}",
			"valorcmbDepartamento" => "",
			"valorcmbMesInicio1" => "01",
			"valorcmbMesInicio2" => "01",
			"valorcmbMesInicio1P" => "01",
			"valorcmbMesInicio2P" => "01",
			"valorcmbOrder" => "",
			"valorcmbTipo" => "",
			"valorcmbOrganismo" => "{VALORMNUORGANISMO}",
			"form[txtEntidad]" => "",
			"form[mnuDepartamento]" => "",
			"form[txtCUCE1]" => "",
			"form[txtCUCE2]" => "",
			"form[txtCUCE3]" => "",
			"form[txtCUCE4]" => "",
			"form[txtCUCE5]" => "",
			"form[txtCUCE6]" => "",
			"form[txtObjeto]" => "",
			"form[mnuTipo]" => "",
			"form[mnuModalidad]" => "",
			"form[txtNumcontrato]" => "",
			"form[mnuEstado]" => "",
			"form[mnuNormativa]" => "",
			"form[txtMonto1]" => "",
			"form[txtMonto2]" => "",
			"form[txtDiaInicio]" => "",
			"form[cmbMesInicio]" => "01",
			"form[txtAnioInicio]" => "",
			"form[txtDiaInicio2]" => "",
			"form[cmbMesInicio2]" => "01",
			"form[txtAnioInicio2]" => "",
			"form[txtDiaInicioP]" => "",
			"form[cmbMesInicioP]" => "01",
			"form[txtAnioInicioP]" => "",
			"form[txtDiaInicio2P]" => "",
			"form[cmbMesInicio2P]" => "01",
			"form[txtAnioInicio2P]" => "",
			"form[txtDiaInicioA]" => "",
			"form[cmbMesInicioA]" => "01",
			"form[txtAnioInicioA]" => "",
			"form[txtDiaInicio2A]" => "",
			"form[cmbMesInicio2A]" => "01",
			"form[txtAnioInicio2A]" => "",
			"form[cmbOrder]" => "D",
			"form[txtNumregistros]" => "30",
			"form[chkPrecio]" => "r.descripcionrubro",
			"form[chkGarantia]" => "da.numitems",
			"form[chkPliego]" => "items",
			"form[chkRpc]" => "i.codigonormativa",
			"form[chkReunion]" => "n.codigotipodocumento || '-' || n.numerodocumento",
			"form[chkAdjudicacion]" => "i.fechainicioventapliegos",
			"form[chkDepartamento]" => "e.codigodepartamento",
			"form[chkNormativa]" => "i.codigomodalidad",
			"Submit" => "Buscar" 
		}

		a.get('https://www.sicoes.gob.bo/contrat/procesos-av.php', data) do |page|
			tables = page.search('table')
			puts "Probando"
			pages_number = page.at('font:contains("Pagina 1")').text.split("/")[1]
			puts pages_number

			trs = tables[17].search('tr')

			trs.each do |tr|

				puts tr
				tds = tr.search('td')
				puts tds[0];

				nbsp = Nokogiri::HTML("&nbsp;").text
				puts tds[0].text.gsub(nbsp, " ") if tds[0]

				if tds[0] 
					c = Contract.new
				    c.origin_id = tds[1].text.strip

				    entity = Entity.where(name: tds[2].text.upcase.strip).first_or_create
				    c.entity_id = entity.id

				    mode = Mode.where(origin_code: tds[3].text.upcase.strip).first_or_create
				    c.mode_id = mode.id

				    c.control_number = tds[4].text.strip

				    c.publication_number = tds[5].text.gsub(nbsp, " ").strip.to_i
				    c.description = tds[6].text.strip

				    div = tds[7].search('div')
				    status = Status.where(name: div[0].text.upcase.strip).first_or_create
				    c.status_id = status.id


				    div = tds[8].search('div')
				    contracted_amount = div[0].text.strip

				    if contracted_amount and contracted_amount != ""
				    	contracted_amount = contracted_amount.gsub(",","").to_d
				    	contracted_amount = Money.new(contracted_amount, 'BOB')
				    else
				    	contracted_amount = nil
				    end

				    c.contracted_amount_cents_money =  contracted_amount


				    c.publication_date = tds[9].text.strip.gsub(nbsp, " ").to_date
				    c.presentation_date = tds[10].text.strip.gsub(nbsp, " ").to_date
				    c.contact = tds[13].text.strip
				    c.warranty = tds[14].text.gsub(nbsp, " ").strip
				    c.specification_price = tds[15].text.gsub(nbsp, " ").strip

				    c.aclaration_date = tds[17].text.gsub(nbsp, " ").strip.to_datetime
				    c.granted_date = ""
				    c.abandonment_date = ""
				    region = Region.where(name: tds[19].text.upcase.strip).first_or_create
				    c.region_id = region.id

				    regulation = Regulation.where(origin_code: tds[20].text.upcase.strip).first_or_create
				    c.regulation_id = regulation.id

				    c.save
				end

				#puts tds[0].content if tds[0]
				#puts tds[2].content if tds[2]
			end
=begin
			a.get('https://www.sicoes.gob.bo/contrat/procesos-av.php?adodb_next_page=2', data) do |page2|


				tables = page2.search('table')

				trs = tables[17].search('tr')

				trs.each do |tr|
					tds = tr.search('td')
					#puts tds[0].content if tds[0]
					#puts tds[2].content if tds[2]
				end

			end
=end

		#	search_result = page.form_with(:id => 'gbqf') do |search|
		#		search.q = 'Hello world'
		#	end.submit

		#	search_result.links.each do |link|
		#		puts link.text
		#	end
		end

		return ""
		
	end
end
