class Crawler < ActiveRecord::Base


	def self.crawl(from_string,to_string)

		a = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
		}


		#from_date = Date.new(year, 1, 1)
		#to_date   = Date.new(year, 12, 31)

		from_date = from_string.to_date
		to_date   = to_string.to_date

		(from_date..to_date).each do |date|  

			date_end = date + 1

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
				"form[mnuEstado]" => "%",
				"form[mnuNormativa]" => "",
				"form[txtMonto1]" => "",
				"form[txtMonto2]" => "",
=begin

				"form[txtDiaInicio]" => "2",
				"form[cmbMesInicio]" => "01",
				"form[txtAnioInicio]" => "2015",
				"form[txtDiaInicio2]" => "3",
				"form[cmbMesInicio2]" => "01",
				"form[txtAnioInicio2]" => "2015",
=end

				"form[txtDiaInicio]" => date.strftime('%-d'),
				"form[cmbMesInicio]" => date.strftime('%m'),
				"form[txtAnioInicio]" => date.strftime('%Y'),
				"form[txtDiaInicio2]" => date_end.strftime('%-d'),
				"form[cmbMesInicio2]" => date_end.strftime('%m'),
				"form[txtAnioInicio2]" => date_end.strftime('%Y'),
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
				"form[txtNumregistros]" => "3000",
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

				trs = tables[17].search('tr')

				trs.each do |tr|

					#puts tr
					tds = tr.search('td')
					#puts tds[0];

					nbsp = Nokogiri::HTML("&nbsp;").text
					#puts tds[0].text.gsub(nbsp, " ") if tds[0]

					if tds[1] 
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
					    	contracted_amount_money = Money.new(contracted_amount, 'BOB')
					    else
					    	contracted_amount_money = nil
					    	contracted_amount = nil
					    end
					    
					    #c.contracted_amount_cents_money =  contracted_amount_money
					    c.contracted_amount =  contracted_amount


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

					    if c.save
							tds[12].search('a').each do |link_form|
								form_link = link_form[:onclick].gsub("openWindow(\'..","").gsub("\');","")
								form_name = link_form.text.strip
								ContractForm.where(contract_id: c.id,
									name: form_name,
									link: form_link
								).first_or_create
							end

							tds[11].search('a').each do |link_document|
								document_link = link_document[:onclick].gsub("openWindow1(\'..","").gsub("\');","")
								document_name = link_document.text.strip
								ContractDocument.where(contract_id: c.id,
									name: document_name,
									link: document_link
								).first_or_create
							end
						end
					end

					#puts tds[0].content if tds[0]
					#puts tds[2].content if tds[2]
				end
			end
		end
		return ""
		
	end



	def self.crawl_forms100

		a = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
		}

		contract_forms = ContractForm.where(name: 'FORM 100').first(500)


		contract_forms.each do |contract_form|

			c = Contract.find(contract_form.contract_id)
			headers = {"Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
					"Cache-Control"	=> "max-age=0",
					"User-Agent" =>	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.5.17 (KHTML, like Gecko) Version/8.0.5 Safari/600.5.17"}

			
			puts contract_form.link

			a.pre_connect_hooks << Proc.new { sleep 0.02 }
			a.get('https://www.sicoes.gob.bo/'+contract_form.link, nil, nil,headers) do |page|
				tables = page.parser.xpath('/html/body/table')
				trs = tables[3].search('tr')[1].css('td').first.css('table').first.search('tr')[1].css('td').first.css('table').first.search('tr');
				
				awarding_type = AwardingType.where(name: trs[1].css('td')[2].text.upcase.strip).first_or_create
				c.awarding_type_id = awarding_type.id

				
				contract_type = ContractType.where(name: trs[3].css('td')[2].text.upcase.strip).first_or_create
				c.contract_type_id = contract_type.id


				selection_method = SelectionMethod.where(name: trs[4].css('td')[2].text.upcase.strip).first_or_create
				c.selection_method_id = selection_method.id

				#c.currency_contract = trs[6].css('td')[2].text.strip

				total_td = tables[4].search('tr')[1].css('td').first.css('table').first.search('tr')[1].css('td').first.css('table').first.css('tr').last.css('td').last;
				specified_amount = total_td.text.gsub(",","").to_d
				c.specified_amount = specified_amount

				c.save

			end

		end

		return ""

	end


	def self.crawl_forms200(init_range, end_range)

		while(1)
			puts "proceso" + init_range.to_s + ".." + end_range.to_s
			crawl_forms200_proc(init_range, end_range)
		end

	end

	def self.crawl_forms200_proc(init_range, end_range)

		a = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
		}

		nbsp = Nokogiri::HTML("&nbsp;").text

		contract_forms = ContractForm.where("contract_forms.name = 'FORM 200'
and contract_forms.id between ? and ?
and exists (select 1
from contracts
where contracts.id = contract_forms.contract_id
and contracts.status_id = 1) 
and not exists (select 1
from contracted_companies
where contracted_companies.contract_id = contract_forms.contract_id)
		", init_range, end_range).order(:id).limit(10);

		contract_forms.each do |contract_form|

			#contract_form = ContractForm.find(472186)

			headers = {"Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
					"Cache-Control"	=> "max-age=0",
					"User-Agent" =>	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.5.17 (KHTML, like Gecko) Version/8.0.5 Safari/600.5.17"}

			c = Contract.find(contract_form.contract_id)

			puts contract_form.link
			puts init_range.to_s + ".." + end_range.to_s
			puts contract_form.id


			a.pre_connect_hooks << Proc.new { sleep 0.01 }
			a.get('https://www.sicoes.gob.bo/'+contract_form.link, nil, nil,headers) do |page|
				
				tables = page.parser.xpath('/html/body/table')
				#Empresas
				trs = tables[2].css('tr');

				#puts trs
				cont  = 0
				length_trs = trs.count


				trs.each do |tr|

					if cont > 2 and cont < (length_trs-1)

	
						tds = tr.css('td')


						if (tds.count >= 5)

							company = Company.where(
								name: tds[4].text.upcase.strip, 
								company_type: "EMPRESA",
								company_origin: tds[1].text.upcase.strip,
								document_type: tds[2].text.upcase.strip,
								document_number: tds[3].text.upcase.strip,
								).first_or_create

							ApplyingCompany.where(
								company_id: company.id,
								contract_id: c.id
							).first_or_create
						end
					end
					cont = cont + 1
				end



				#Sociedades Accidentales
				trs = tables[3].css('tr');
				cont  = 0
				length_trs = trs.count

				trs.each do |tr|
					if cont > 2 and cont < (length_trs-1)
						tds = tr.css('td')
						if (tds.count >= 3)
							company = Company.where(
								name: tds[1].text.upcase.strip, 
								company_type: "SOCIEDAD ACCIDENTAL",
								#company_origin: tds[1].text.upcase.strip,
								#document_type: tds[2].text.upcase.strip,
								#document_number: tds[3].text.upcase.strip,
								).first_or_create
							ApplyingCompany.where(
								company_id: company.id,
								contract_id: c.id
							).first_or_create
						end
					end
					cont = cont + 1
				end

				cont = 0 
				trs = tables[5].css('tr');
				length_trs = trs.count
				trs.each do |tr|
					if cont > 3 and cont < (length_trs-1)


						tds = tr.css('td')
						if (tds.count >= 3)

							company = Company.joins(:applying_companies).where("applying_companies.contract_id = ? and companies.name like ?", c.id, tds[0].text.upcase.strip+"%").first
							if company

								ContractedCompany.where(
									contract_id: c.id, 
									company_id: company.id,
									contract_number: tds[1].text.strip,
									contract_date: tds[2].text.strip.gsub(nbsp, " ").to_date,
									contract_amount: tds[3].text.gsub(",","").to_d,
								).first_or_create

							end
						end
					end
					cont = cont + 1
				end
				#c.save
			end
		end
		return ""

	end


	def self.crawl_forms_200extra

		a = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
		}

		nbsp = Nokogiri::HTML("&nbsp;").text

		contract_forms = ContractForm.where(:contract_id =>
[336523,
119263,
352788,
136016,
335427,
189514,
365665,
344922,
387980,
776,
310771,
133772,
76938,
102002,
321252], :name => ['FORM 200'])

		contract_forms.each do |contract_form|

			#contract_form = ContractForm.find(472186)

			headers = {"Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
					"Cache-Control"	=> "max-age=0",
					"User-Agent" =>	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.5.17 (KHTML, like Gecko) Version/8.0.5 Safari/600.5.17"}

			c = Contract.find(contract_form.contract_id)


			a.pre_connect_hooks << Proc.new { sleep 0.01 }
			a.get('https://www.sicoes.gob.bo/'+contract_form.link, nil, nil,headers) do |page|
				
				tables = page.parser.xpath('/html/body/table')
				#Empresas
				trs = tables[2].css('tr');

				#puts trs
				cont  = 0
				length_trs = trs.count


				trs.each do |tr|

					if cont > 2 and cont < (length_trs-1)

	
						tds = tr.css('td')


						if (tds.count >= 5)

							company = Company.where(
								name: tds[4].text.upcase.strip, 
								company_type: "EMPRESA",
								company_origin: tds[1].text.upcase.strip,
								document_type: tds[2].text.upcase.strip,
								document_number: tds[3].text.upcase.strip,
								).first_or_create

							ApplyingCompany.where(
								company_id: company.id,
								contract_id: c.id
							).first_or_create
						end
					end
					cont = cont + 1
				end



				#Sociedades Accidentales
				trs = tables[3].css('tr');
				cont  = 0
				length_trs = trs.count

				trs.each do |tr|
					if cont > 2 and cont < (length_trs-1)
						tds = tr.css('td')
						if (tds.count >= 3)
							company = Company.where(
								name: tds[1].text.upcase.strip, 
								company_type: "SOCIEDAD ACCIDENTAL",
								#company_origin: tds[1].text.upcase.strip,
								#document_type: tds[2].text.upcase.strip,
								#document_number: tds[3].text.upcase.strip,
								).first_or_create
							ApplyingCompany.where(
								company_id: company.id,
								contract_id: c.id
							).first_or_create
						end
					end
					cont = cont + 1
				end

				cont = 0 
				trs = tables[5].css('tr');
				length_trs = trs.count
				trs.each do |tr|
					if cont > 3 and cont < (length_trs-1)

						tds = tr.css('td')
						if (tds.count >= 3)

							company = Company.joins(:applying_companies).where("applying_companies.contract_id = ? and companies.name like ?", c.id, tds[0].text.upcase.strip+"%").first
							if company

								ContractedCompany.where(
									contract_id: c.id, 
									company_id: company.id,
									contract_number: tds[1].text.strip,
									contract_date: tds[2].text.strip.gsub(nbsp, " ").to_date,
									contract_amount: tds[3].text.gsub(",","").to_d,
								).first_or_create

							end
						end
					end
					cont = cont + 1
				end
				#c.save
			end
		end
		return ""

	end
	def self.crawl_forms400(init_range, end_range)
		restantes = 1
		cont = 0
		while(restantes > 0 and cont < 2500 )
			puts "proceso" + init_range.to_s + ".." + end_range.to_s
			begin
				restantes = crawl_forms400_proc(init_range, end_range)
			rescue StandardError => e
				puts e
			end
			cont = cont + 1
			puts cont
		end
		puts "Finalizo"
		puts restantes
		puts cont
	end

	def self.crawl_forms400_one

		a = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
		}

		nbsp = Nokogiri::HTML("&nbsp;").text


		contract_form = ContractForm.find(523988)

			#contract_form = ContractForm.find(1)

			c = Contract.find(contract_form.contract_id)
			headers = {"Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
					"Cache-Control"	=> "max-age=0",
					"User-Agent" =>	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.5.17 (KHTML, like Gecko) Version/8.0.5 Safari/600.5.17"}

			

			a.pre_connect_hooks << Proc.new { sleep 0.1 }
			a.get('https://www.sicoes.gob.bo/'+contract_form.link, nil, nil,headers) do |page|
				tables = page.parser.xpath('/html/body/table')
				

				#Empresas
				trs = tables[3].css('tr')
				cont  = 0
				length_trs = trs.count

				trs.each do |tr|
					#puts cont
					#puts tr
					if cont > 2
						tds = tr.css('td')
						if (tds.count >= 3) and tds[4].text.upcase.strip != ""
							company = Company.where(
								name: tds[4].text.upcase.strip, 
								company_type: "EMPRESA",
								company_origin: tds[1].text.upcase.strip,
								document_type: tds[2].text.upcase.strip,
								document_number: tds[3].text.upcase.strip,
								).first_or_create
							ContractedCompany.where(
									company_id: company.id,
									contract_id: c.id
							).first_or_create
						end
					end
					cont = cont + 1
				end


				#Sociedades Accidentales
				trs = tables[4].css('tr');
				cont  = 0
				length_trs = trs.count
				trs.each do |tr|
					if cont > 2
						tds = tr.css('td')
						if (tds.count >= 3) and tds[1].text.upcase.strip != ""
							company = Company.where(
								name: tds[1].text.upcase.strip, 
								company_type: "SOCIEDAD ACCIDENTAL",
								#company_origin: tds[1].text.upcase.strip,
								#document_type: tds[2].text.upcase.strip,
								#document_number: tds[3].text.upcase.strip,
								).first_or_create
							ContractedCompany.where(
									company_id: company.id,
									contract_id: c.id
							).first_or_create
						end
					end
					cont = cont + 1
				end

				#Costo del contrato
				trs = tables[6].css('tr');
				length_trs = trs.count

				if length_trs > 1
					#tr = trs[1]
					cont  = 0
					trs.each do |tr|
						if cont > 0
							tds = tr.css('td')
							puts tds
							contracted_company = ContractedCompany.joins(:company).where("contracted_companies.contract_id = ? and companies.name like ?", c.id, tds[0].text.upcase.strip+"%").readonly(false).first
							if contracted_company
								contracted_company.contract_number =  tds[1].text.strip
								contracted_company.contract_date = tds[2].text.strip.gsub(nbsp, " ").to_date
								contracted_company.contract_amount = tds[3].text.gsub(",","").to_d
								contracted_company.save
							end
						end
						cont = cont + 1
					end
				end

				#Items
				trs = tables[8].css('tr');
				length_trs = trs.count
				if length_trs > 1

					cont  = 0
					trs.each do |tr|
						if cont > 0
							tds = tr.css('td')
							puts tds

							if (tds.count > 3)
								budget_item = BudgetItem.first_or_create(item_number: tds[1].text.strip)

								ContractBudgetItem.where(
									contract_id: c.id,
									budget_item_id: budget_item.id,
									description: tds[2].text.upcase.strip,
									contract_number: tds[3].text.strip,
									unit_price: tds[4].text.gsub(",","").to_d,
									quantity_type: tds[5].text.upcase.strip,
									quantity: tds[6].text.gsub(",","").to_d,
									total: tds[7].text.gsub(",","").to_d,
									origin: tds[8].text.upcase.strip
								).first_or_create
							end
						end
						cont = cont + 1
					end
				end

				#tipo de contrato
				trs = tables[2].css('tr');

				contract_type = ContractType.where(name: trs[2].css('td')[1].text.upcase.strip).first_or_create
				c.contract_type_id = contract_type.id
				c.save
			end




		return ""

	end

	def self.random_ip
		a = [["81.163.36.137",8080],
		["220.255.3.170",80]
		]		
		return a.sample
	end

	def self.crawl_forms400_proc(init_range, end_range)


		a = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
			#agent.set_proxy(proxy[0], proxy[1])
		}


		nbsp = Nokogiri::HTML("&nbsp;").text

		contract_forms = ContractForm.where("contract_forms.name = 'FORM 400'
and contract_forms.id between ? and ?
and exists (select 1
from contracts
where contracts.id = contract_forms.contract_id
and contracts.status_id = 1) 
and not exists (select 1
from contracted_companies
where contracted_companies.contract_id = contract_forms.contract_id)
		", init_range, end_range).order(:id).limit(20);

		restantes = contract_forms.count

		contract_forms.each do |contract_form|

			c = Contract.find(contract_form.contract_id)
			headers = {"Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
					"Cache-Control"	=> "max-age=0",
					"User-Agent" =>	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.5.17 (KHTML, like Gecko) Version/8.0.5 Safari/600.5.17"}

			

			a.pre_connect_hooks << Proc.new { sleep 0.1 }
			a.get('https://www.sicoes.gob.bo/'+contract_form.link, nil, nil,headers) do |page|
				tables = page.parser.xpath('/html/body/table')
				

				#Empresas
				trs = tables[3].css('tr')
				cont  = 0
				length_trs = trs.count

				trs.each do |tr|
					#puts cont
					#puts tr
					if cont > 2
						tds = tr.css('td')
						if (tds.count >= 3) and tds[4].text.upcase.strip != ""
							company = Company.where(
								name: tds[4].text.upcase.strip, 
								company_type: "EMPRESA",
								company_origin: tds[1].text.upcase.strip,
								document_type: tds[2].text.upcase.strip,
								document_number: tds[3].text.upcase.strip,
								).first_or_create
							ContractedCompany.where(
									company_id: company.id,
									contract_id: c.id
							).first_or_create
						end
					end
					cont = cont + 1
				end


				#Sociedades Accidentales
				trs = tables[4].css('tr');
				cont  = 0
				length_trs = trs.count
				trs.each do |tr|
					if cont > 2
						tds = tr.css('td')
						if (tds.count >= 3) and tds[1].text.upcase.strip != ""
							company = Company.where(
								name: tds[1].text.upcase.strip, 
								company_type: "SOCIEDAD ACCIDENTAL",
								#company_origin: tds[1].text.upcase.strip,
								#document_type: tds[2].text.upcase.strip,
								#document_number: tds[3].text.upcase.strip,
								).first_or_create
							ContractedCompany.where(
									company_id: company.id,
									contract_id: c.id
							).first_or_create
						end
					end
					cont = cont + 1
				end

				#Costo del contrato
				trs = tables[6].css('tr');
				length_trs = trs.count

				if length_trs > 1
					#tr = trs[1]
					cont  = 0
					trs.each do |tr|
						if cont > 0
							tds = tr.css('td')
							#puts tds
							contracted_company = ContractedCompany.joins(:company).where("contracted_companies.contract_id = ? and companies.name like ?", c.id, tds[0].text.upcase.strip+"%").readonly(false).first
							if contracted_company
								contracted_company.contract_number =  tds[1].text.strip
								contracted_company.contract_date = tds[2].text.strip.gsub(nbsp, " ").to_date
								contracted_company.contract_amount = tds[3].text.gsub(",","").to_d
								contracted_company.save
							end
						end
						cont = cont + 1
					end
				end

				#Items
				trs = tables[8].css('tr');
				length_trs = trs.count
				if length_trs > 1

					cont  = 0
					trs.each do |tr|
						if cont > 0
							tds = tr.css('td')
							#puts tds

							if (tds.count > 3)
								budget_item = BudgetItem.first_or_create(item_number: tds[1].text.strip)

								ContractBudgetItem.where(
									contract_id: c.id,
									budget_item_id: budget_item.id,
									description: tds[2].text.upcase.strip,
									contract_number: tds[3].text.strip,
									unit_price: tds[4].text.gsub(",","").to_d,
									quantity_type: tds[5].text.upcase.strip,
									quantity: tds[6].text.gsub(",","").to_d,
									total: tds[7].text.gsub(",","").to_d,
									origin: tds[8].text.upcase.strip
								).first_or_create
							end
						end
						cont = cont + 1
					end
				end

				#tipo de contrato
				trs = tables[2].css('tr');

				motive = Motive.where(name: trs[2].css('td')[0].text.upcase.strip).first_or_create
				c.motive_id = motive.id

				contract_type = ContractType.where(name: trs[2].css('td')[1].text.upcase.strip).first_or_create
				c.contract_type_id = contract_type.id
				c.save


			end
		end

		return restantes

	end


	def self.crawl_forms400_extra

		a = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
		}

		contract_forms = ContractForm.where(:contract_id =>
[336523,
119263,
352788,
136016,
335427,
189514,
365665,
344922,
387980,
776,
310771,
133772,
76938,
102002,
321252], :name => ['FORM 400'])

   
		contract_forms.each do |contract_form|


			#contract_form = ContractForm.find(1)

			c = Contract.find(contract_form.contract_id)
			headers = {"Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
					"Cache-Control"	=> "max-age=0",
					"User-Agent" =>	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.5.17 (KHTML, like Gecko) Version/8.0.5 Safari/600.5.17"}



			a.pre_connect_hooks << Proc.new { sleep 0.02 }
			a.get('https://www.sicoes.gob.bo/'+contract_form.link, nil, nil,headers) do |page|
				tables = page.parser.xpath('/html/body/table')
				

				#Empresas
				trs = tables[3].css('tr')
				cont  = 0
				length_trs = trs.count

				trs.each do |tr|
					#puts cont
					#puts tr
					if cont > 2 and cont < (length_trs-1)
						tds = tr.css('td')
						if (tds.count >= 3)
							company = Company.where(
								name: tds[4].text.upcase.strip, 
								company_type: "EMPRESA",
								company_origin: tds[1].text.upcase.strip,
								document_type: tds[2].text.upcase.strip,
								document_number: tds[3].text.upcase.strip,
								).first_or_create
							ContractedCompany.where(
									company_id: company.id,
									contract_id: c.id
							).first_or_create
						end
					end
					cont = cont + 1
				end


				#Sociedades Accidentales
				trs = tables[4].css('tr');
				cont  = 0
				length_trs = trs.count
				trs.each do |tr|
					if cont > 2 and cont < (length_trs-1)
						tds = tr.css('td')
						if (tds.count >= 3)
							company = Company.where(
								name: tds[1].text.upcase.strip, 
								company_type: "SOCIEDAD ACCIDENTAL",
								#company_origin: tds[1].text.upcase.strip,
								#document_type: tds[2].text.upcase.strip,
								#document_number: tds[3].text.upcase.strip,
								).first_or_create
							ContractedCompany.where(
									company_id: company.id,
									contract_id: c.id
							).first_or_create
						end
					end
					cont = cont + 1
				end
			end

		end

		return ""

	end


	def self.temp
BudgetItem.create([{ origin_number: ' 1'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11100'.to_i.to_s, name: 'Haberes Basicos'.strip.upcase }, 
{ origin_number: ' 2'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11200'.to_i.to_s, name: 'Bono de Antiguedad'.strip.upcase }, 
{ origin_number: ' 3'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11210'.to_i.to_s, name: 'Categorias Magisterio'.strip.upcase }, 
{ origin_number: ' 4'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11220'.to_i.to_s, name: 'Otras Instituciones'.strip.upcase }, 
{ origin_number: ' 5'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11300'.to_i.to_s, name: 'Bonificaciones'.strip.upcase }, 
{ origin_number: ' 6'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11310'.to_i.to_s, name: 'Bono de Frontera'.strip.upcase }, 
{ origin_number: ' 7'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11320'.to_i.to_s, name: 'Categorias Medicas'.strip.upcase }, 
{ origin_number: ' 8'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11330'.to_i.to_s, name: 'Otras Bonificaciones'.strip.upcase }, 
{ origin_number: ' 9'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11400'.to_i.to_s, name: 'Aguinaldos'.strip.upcase }, 
{ origin_number: ' 10'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11500'.to_i.to_s, name: 'Primas'.strip.upcase }, 
{ origin_number: ' 11'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11600'.to_i.to_s, name: 'Asignaciones Familiares'.strip.upcase }, 
{ origin_number: ' 12'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11700'.to_i.to_s, name: 'Sueldos'.strip.upcase }, 
{ origin_number: ' 13'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11800'.to_i.to_s, name: 'Dietas'.strip.upcase }, 
{ origin_number: ' 14'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11810'.to_i.to_s, name: 'Dietas de Directorios'.strip.upcase }, 
{ origin_number: ' 15'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11820'.to_i.to_s, name: 'Dietas de Concejos'.strip.upcase }, 
{ origin_number: ' 16'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11900'.to_i.to_s, name: 'Otros Servicios Personales'.strip.upcase }, 
{ origin_number: ' 17'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11910'.to_i.to_s, name: 'Horas Extraordinarias'.strip.upcase }, 
{ origin_number: ' 18'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11920'.to_i.to_s, name: 'Vacaciones no Utilizadas'.strip.upcase }, 
{ origin_number: ' 19'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 11930'.to_i.to_s, name: 'Otros'.strip.upcase }, 
{ origin_number: ' 20'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 12100'.to_i.to_s, name: 'Personal Eventual'.strip.upcase }, 
{ origin_number: ' 21'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 13100'.to_i.to_s, name: 'Aporte Patronal al Seguro Social'.strip.upcase }, 
{ origin_number: ' 22'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 13110'.to_i.to_s, name: 'Regimen de Corto Plazo (Salud)'.strip.upcase }, 
{ origin_number: ' 23'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 13120'.to_i.to_s, name: 'Regimen de Largo Plazo(Pensiones)'.strip.upcase }, 
{ origin_number: ' 24'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 13200'.to_i.to_s, name: 'Aporte Patronal para Vivienda'.strip.upcase }, 
{ origin_number: ' 25'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 14100'.to_i.to_s, name: 'Otros'.strip.upcase }, 
{ origin_number: ' 26'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 15100'.to_i.to_s, name: 'Incremento Salarial'.strip.upcase }, 
{ origin_number: ' 27'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 15200'.to_i.to_s, name: 'Crecimiento Vegetativo'.strip.upcase }, 
{ origin_number: ' 28'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 15300'.to_i.to_s, name: 'Creacion de Itemes'.strip.upcase }, 
{ origin_number: ' 29'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 15400'.to_i.to_s, name: 'Otras Previsiones'.strip.upcase }, 
{ origin_number: ' 30'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 21100'.to_i.to_s, name: 'Comunicaciones'.strip.upcase }, 
{ origin_number: ' 31'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 21200'.to_i.to_s, name: 'Energia Electrica'.strip.upcase }, 
{ origin_number: ' 32'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 21300'.to_i.to_s, name: 'Agua'.strip.upcase }, 
{ origin_number: ' 33'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 21400'.to_i.to_s, name: 'Servicios Telefonicos'.strip.upcase }, 
{ origin_number: ' 34'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 21500'.to_i.to_s, name: 'Gas Domiciliario'.strip.upcase }, 
{ origin_number: ' 35'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 21600'.to_i.to_s, name: 'Servicios de Internet y Otros'.strip.upcase }, 
{ origin_number: ' 36'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 22100'.to_i.to_s, name: 'Pasajes'.strip.upcase }, 
{ origin_number: ' 37'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 22110'.to_i.to_s, name: 'Pasajes al Interior del País'.strip.upcase }, 
{ origin_number: ' 38'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 22120'.to_i.to_s, name: 'Pasajes al Exterior del País'.strip.upcase }, 
{ origin_number: ' 39'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 22200'.to_i.to_s, name: 'Viaticos'.strip.upcase }, 
{ origin_number: ' 40'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 22300'.to_i.to_s, name: 'Fletes y Almacenamiento'.strip.upcase }, 
{ origin_number: ' 41'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 22400'.to_i.to_s, name: 'Gastos de Instalacion y Retorno'.strip.upcase }, 
{ origin_number: ' 42'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 22500'.to_i.to_s, name: 'Seguros'.strip.upcase }, 
{ origin_number: ' 43'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 22600'.to_i.to_s, name: 'Transporte de Personal'.strip.upcase }, 
{ origin_number: ' 44'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 23100'.to_i.to_s, name: 'Edificios'.strip.upcase }, 
{ origin_number: ' 45'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 23200'.to_i.to_s, name: 'Equipos y Maquinarias'.strip.upcase }, 
{ origin_number: ' 46'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 23300'.to_i.to_s, name: 'Alquiler de Tierras y Terrenos'.strip.upcase }, 
{ origin_number: ' 47'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 23400'.to_i.to_s, name: 'Otros Alquileres'.strip.upcase }, 
{ origin_number: ' 48'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 24100'.to_i.to_s, name: 'Edificios y Equipos'.strip.upcase }, 
{ origin_number: ' 49'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 24110'.to_i.to_s, name: 'Mantenimiento de Edificios'.strip.upcase }, 
{ origin_number: ' 50'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 24120'.to_i.to_s, name: 'Matenimiento Equipos'.strip.upcase }, 
{ origin_number: '51'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 24130'.to_i.to_s, name: 'Matenimiento y Reparacion de Muebles y Enseres'.strip.upcase }, 
{ origin_number: ' 52'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 24200'.to_i.to_s, name: 'Vias de Comunicacion'.strip.upcase }, 
{ origin_number: ' 53'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 24300'.to_i.to_s, name: 'Otros Gastos por Concepto de Mantenimiento y Reparacion'.strip.upcase }, 
{ origin_number: ' 54'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25100'.to_i.to_s, name: 'Medicos, Sanitarios y Sociales'.strip.upcase }, 
{ origin_number: ' 55'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25120'.to_i.to_s, name: 'Gastos Especializados por Atención Médica y otros'.strip.upcase }, 
{ origin_number: ' 56'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25200'.to_i.to_s, name: 'Estudios e Investigaciones'.strip.upcase }, 
{ origin_number: ' 57'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25210'.to_i.to_s, name: 'Consultorías por Producto'.strip.upcase }, 
{ origin_number: ' 58'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25220'.to_i.to_s, name: 'Consultores en Línea'.strip.upcase }, 
{ origin_number: ' 59'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25230'.to_i.to_s, name: 'Auditorias Externas'.strip.upcase }, 
{ origin_number: ' 60'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25300'.to_i.to_s, name: 'Comisiones y Gastos Bancarios'.strip.upcase }, 
{ origin_number: ' 61'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25400'.to_i.to_s, name: 'Lavanderia, Limpieza e Higiene'.strip.upcase }, 
{ origin_number: ' 62'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25500'.to_i.to_s, name: 'Publicidad'.strip.upcase }, 
{ origin_number: ' 63'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25600'.to_i.to_s, name: 'Imprenta'.strip.upcase }, 
{ origin_number: ' 64'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25700'.to_i.to_s, name: 'Capacitacion del Personal'.strip.upcase }, 
{ origin_number: ' 65'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25800'.to_i.to_s, name: 'Estudios e Investigaciones para Proyectos de Inversion'.strip.upcase }, 
{ origin_number: ' 66'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25810'.to_i.to_s, name: 'Consultorías por Producto'.strip.upcase }, 
{ origin_number: ' 67'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25820'.to_i.to_s, name: 'Consultores de Línea'.strip.upcase }, 
{ origin_number: ' 68'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 25900'.to_i.to_s, name: 'Servicios Tecnicos y Otros'.strip.upcase }, 
{ origin_number: ' 69'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 26100'.to_i.to_s, name: 'Gastos Especificos de la Administracion Central'.strip.upcase }, 
{ origin_number: ' 70'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 26200'.to_i.to_s, name: 'Gastos Judiciales'.strip.upcase }, 
{ origin_number: ' 71'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 26300'.to_i.to_s, name: 'Derechos sobre Bienes Intangibles'.strip.upcase }, 
{ origin_number: ' 72'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 26400'.to_i.to_s, name: 'Servicios de Seguridad y Vigilancia'.strip.upcase }, 
{ origin_number: ' 73'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 26610'.to_i.to_s, name: 'Servicios Publicos'.strip.upcase }, 
{ origin_number: ' 74'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 26620'.to_i.to_s, name: 'Servicios privados'.strip.upcase }, 
{ origin_number: ' 75'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 26630'.to_i.to_s, name: 'Servicio por traslado de valores'.strip.upcase }, 
{ origin_number: ' 76'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 26900'.to_i.to_s, name: 'Otros Servicios No Personales'.strip.upcase }, 
{ origin_number: ' 77'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 26910'.to_i.to_s, name: 'Gastos de Representacion'.strip.upcase }, 
{ origin_number: ' 78'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 26920'.to_i.to_s, name: 'Fallas de Caja'.strip.upcase }, 
{ origin_number: ' 79'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 26990'.to_i.to_s, name: 'Otros'.strip.upcase }, 
{ origin_number: ' 80'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 31100'.to_i.to_s, name: 'Alimentos y Bebidas para Personas y Desayuno Escolar'.strip.upcase }, 
{ origin_number: ' 81'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 31110'.to_i.to_s, name: 'Refrigerios y Gastos Administrativos'.strip.upcase }, 
{ origin_number: ' 82'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 31120'.to_i.to_s, name: 'Gastos por Alimentacion y Otros Similares efectuados en Reuniones, Seminarios y Otros Eventos'.strip.upcase }, 
{ origin_number: ' 83'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 31130'.to_i.to_s, name: 'Desayuno Escolar'.strip.upcase }, 
{ origin_number: ' 84'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 31140'.to_i.to_s, name: 'Alimentacion Hospitalaria, Penitenciaria y Otras Especificas'.strip.upcase }, 
{ origin_number: ' 85'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 31150'.to_i.to_s, name: '31150 Alimentos y Bebidas para la atención de emergencias y desastres naturales'.strip.upcase }, 
{ origin_number: ' 86'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 31200'.to_i.to_s, name: 'Alimentos para Animales'.strip.upcase }, 
{ origin_number: ' 87'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 31300'.to_i.to_s, name: 'Productos Agroforestales y Pecuarios'.strip.upcase }, 
{ origin_number: ' 88'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 32100'.to_i.to_s, name: 'Papel de Escritorio'.strip.upcase }, 
{ origin_number: ' 89'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 32200'.to_i.to_s, name: 'Productos de Artes Graficas, Papel y Carton'.strip.upcase }, 
{ origin_number: ' 90'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 32300'.to_i.to_s, name: 'Libros y Revistas'.strip.upcase }, 
{ origin_number: ' 91'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 32400'.to_i.to_s, name: 'Textos de Ense?anza'.strip.upcase }, 
{ origin_number: ' 92'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 32500'.to_i.to_s, name: 'Periodicos'.strip.upcase }, 
{ origin_number: ' 93'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 33100'.to_i.to_s, name: 'Hilados y Telas'.strip.upcase }, 
{ origin_number: ' 94'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 33200'.to_i.to_s, name: 'Confecciones Textiles'.strip.upcase }, 
{ origin_number: ' 95'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 33300'.to_i.to_s, name: 'Prendas de Vestir'.strip.upcase }, 
{ origin_number: ' 96'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 33400'.to_i.to_s, name: 'Calzados'.strip.upcase }, 
{ origin_number: ' 97'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 34100'.to_i.to_s, name: 'Combustibles y Lubricantes'.strip.upcase }, 
{ origin_number: ' 98'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 34110'.to_i.to_s, name: 'Combustibles y Lubricantes para Consumo'.strip.upcase }, 
{ origin_number: ' 99'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 34120'.to_i.to_s, name: 'Combustibles y Lubricantes para Comercializacion'.strip.upcase }, 
{ origin_number: ' 100'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 34200'.to_i.to_s, name: 'Productos Quimicos y Farmaceuticos'.strip.upcase }, 
{ origin_number: '101'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 34300'.to_i.to_s, name: 'Llantas y Neumaticos'.strip.upcase }, 
{ origin_number: ' 102'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 34400'.to_i.to_s, name: 'Productos de Cuero y Caucho'.strip.upcase }, 
{ origin_number: ' 103'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 34500'.to_i.to_s, name: 'Productos de Minerales no Metalicos y Plasticos'.strip.upcase }, 
{ origin_number: ' 104'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 34600'.to_i.to_s, name: 'Productos Metalicos'.strip.upcase }, 
{ origin_number: ' 105'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 34700'.to_i.to_s, name: 'Minerales'.strip.upcase }, 
{ origin_number: ' 106'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 34800'.to_i.to_s, name: 'Herramientas Menores'.strip.upcase }, 
{ origin_number: ' 107'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 34900'.to_i.to_s, name: 'Material y Equipo Militar'.strip.upcase }, 
{ origin_number: ' 108'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 39100'.to_i.to_s, name: 'Material de Limpieza'.strip.upcase }, 
{ origin_number: ' 109'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 39200'.to_i.to_s, name: 'Material Deportivo y Recreativo'.strip.upcase }, 
{ origin_number: ' 110'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 39300'.to_i.to_s, name: 'Utensilios de Cocina y Comedor'.strip.upcase }, 
{ origin_number: ' 111'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 39400'.to_i.to_s, name: 'Instrumental Menor Medico Quirurgico'.strip.upcase }, 
{ origin_number: ' 112'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 39500'.to_i.to_s, name: 'Utiles de Escritorio y Oficina'.strip.upcase }, 
{ origin_number: ' 113'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 39600'.to_i.to_s, name: 'Utiles Educacionales y Culturales'.strip.upcase }, 
{ origin_number: ' 114'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 39700'.to_i.to_s, name: 'Utiles y Materiales Electricos'.strip.upcase }, 
{ origin_number: ' 115'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 39800'.to_i.to_s, name: 'Otros Repuestos y Accesorios'.strip.upcase }, 
{ origin_number: ' 116'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 39900'.to_i.to_s, name: 'Otros Materiales y Suministros'.strip.upcase }, 
{ origin_number: ' 117'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 39910'.to_i.to_s, name: 'Acu?acion de Monedas e Impresion de Billetes'.strip.upcase }, 
{ origin_number: ' 118'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 39990'.to_i.to_s, name: 'Otros Materiales y Suministros'.strip.upcase }, 
{ origin_number: ' 119'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 41100'.to_i.to_s, name: 'Edificios'.strip.upcase }, 
{ origin_number: ' 120'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 41200'.to_i.to_s, name: 'Tierras y Terrenos'.strip.upcase }, 
{ origin_number: ' 121'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 41300'.to_i.to_s, name: 'Otras Adquisiciones'.strip.upcase }, 
{ origin_number: ' 122'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 42200'.to_i.to_s, name: 'Construcciones y Mejoras de Bienes Nacionales de Dominio Privado'.strip.upcase }, 
{ origin_number: ' 123'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 42210'.to_i.to_s, name: 'Construcciones y Mejoras de Viviendas'.strip.upcase }, 
{ origin_number: ' 124'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 42220'.to_i.to_s, name: 'Construciones y Mejoras para Defensa y Seguridad'.strip.upcase }, 
{ origin_number: ' 125'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 42230'.to_i.to_s, name: 'Otras Construcciones y Mejoras de Bienes de Dominio Privado'.strip.upcase }, 
{ origin_number: ' 126'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 42240'.to_i.to_s, name: 'Supervision de Construciones y Mejoras de Bienes de Dominio Privado'.strip.upcase }, 
{ origin_number: ' 127'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 42300'.to_i.to_s, name: 'Construcciones y Mejoras de Bienes Nacionales de Dominio Publico'.strip.upcase }, 
{ origin_number: ' 128'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 42310'.to_i.to_s, name: 'Construcciones y Mejoras de Bienes de Dominio Publico'.strip.upcase }, 
{ origin_number: ' 129'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 42320'.to_i.to_s, name: 'Supervision de Construciones y Mejoras de Bienes de Dominio Publico'.strip.upcase }, 
{ origin_number: ' 130'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43100'.to_i.to_s, name: 'Equipo de Oficina y Muebles'.strip.upcase }, 
{ origin_number: ' 131'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43110'.to_i.to_s, name: 'Equipo de Oficina y Muebles'.strip.upcase }, 
{ origin_number: ' 132'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43120'.to_i.to_s, name: 'Equipo de Computacion'.strip.upcase }, 
{ origin_number: ' 133'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43200'.to_i.to_s, name: 'Maquinaria y Equipo de Produccion'.strip.upcase }, 
{ origin_number: ' 134'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43300'.to_i.to_s, name: 'Equipo de Transporte, Traccion y Elevacion'.strip.upcase }, 
{ origin_number: ' 135'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43310'.to_i.to_s, name: 'Vehiculos Livianos para Funciones Administrativas'.strip.upcase }, 
{ origin_number: ' 136'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43320'.to_i.to_s, name: 'Vehiculos Livianos para Proyectos de Inversion Publica'.strip.upcase }, 
{ origin_number: ' 137'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43330'.to_i.to_s, name: 'Maquinaria y Equipo de Transporte de Traccion'.strip.upcase }, 
{ origin_number: ' 138'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43340'.to_i.to_s, name: 'Equipo de Elevacion'.strip.upcase }, 
{ origin_number: ' 139'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43400'.to_i.to_s, name: 'Equipo Medico y de Laboratorio'.strip.upcase }, 
{ origin_number: ' 140'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43500'.to_i.to_s, name: 'Equipo de Comunicaciones'.strip.upcase }, 
{ origin_number: ' 141'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43600'.to_i.to_s, name: 'Equipo Educacional y Recreativo'.strip.upcase }, 
{ origin_number: ' 142'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 43700'.to_i.to_s, name: 'Otra Maquinaria y Equipo'.strip.upcase }, 
{ origin_number: ' 143'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 46100'.to_i.to_s, name: 'Para Construcciones de Bienes de Dominio Privado'.strip.upcase }, 
{ origin_number: ' 144'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 46110'.to_i.to_s, name: 'Consultoría por producto para construcciones de Bienes Públicos de Dominio Privado'.strip.upcase }, 
{ origin_number: ' 145'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 46120'.to_i.to_s, name: 'Consultoría en Línea para construcciones de Bienes de Dominio Privado'.strip.upcase }, 
{ origin_number: ' 146'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 46200'.to_i.to_s, name: 'Para Construcciones de Bienes de Dominio Publico'.strip.upcase }, 
{ origin_number: ' 147'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 46210'.to_i.to_s, name: 'Consultoria por Producto para Construcciones de Bienes de Dominio Publico'.strip.upcase }, 
{ origin_number: ' 148'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 46220'.to_i.to_s, name: 'Consultoria en Linea para Construcciones de Bienes de Dominio Publico'.strip.upcase }, 
{ origin_number: ' 149'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 46300'.to_i.to_s, name: 'Consultoria para capacitacion transferencias de tecnologia y organizacion'.strip.upcase }, 
{ origin_number: ' 150'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 46310'.to_i.to_s, name: 'Consultoria por Producto'.strip.upcase }, 
{ origin_number: ' 151'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 46320'.to_i.to_s, name: 'Consultoria de Linea'.strip.upcase }, 
{ origin_number: ' 152'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 49100'.to_i.to_s, name: 'Activos Intangibles'.strip.upcase }, 
{ origin_number: ' 153'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 49200'.to_i.to_s, name: 'Compra de Bienes Muebles Existentes (usados)'.strip.upcase }, 
{ origin_number: ' 154'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 49300'.to_i.to_s, name: 'Semovientes y Otros Animales'.strip.upcase }, 
{ origin_number: ' 155'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 49400'.to_i.to_s, name: 'Bienes Culturales'.strip.upcase }, 
{ origin_number: ' 156'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 49900'.to_i.to_s, name: 'Otros Activos Fijos'.strip.upcase }, 
{ origin_number: ' 157'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 51100'.to_i.to_s, name: 'Acciones y Participaciones de Capital en Empresas Privadas Nacionales'.strip.upcase }, 
{ origin_number: ' 158'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 51200'.to_i.to_s, name: 'Acciones y Participaciones de Capital en Empresas Publicas No Financieras Nacionales'.strip.upcase }, 
{ origin_number: ' 159'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 51300'.to_i.to_s, name: 'Acciones y Participaciones de Capital en Empresas Publicas No Financieras de las Prefecturas'.strip.upcase }, 
{ origin_number: ' 160'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 51400'.to_i.to_s, name: 'Acciones y Participaciones de Capital en Empresas Publicas No Financieras Municipales'.strip.upcase }, 
{ origin_number: ' 161'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 51500'.to_i.to_s, name: 'Acciones y Participaciones de Capital en Instituciones Publicas Financieras No Bancarias'.strip.upcase }, 
{ origin_number: ' 162'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 51600'.to_i.to_s, name: 'Acciones y Participaciones de Capital en Instituciones Publicas Financieras Bancarias'.strip.upcase }, 
{ origin_number: ' 163'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 51700'.to_i.to_s, name: 'Acciones y Participaciones de Capital en Organismos Internacionales'.strip.upcase }, 
{ origin_number: ' 164'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 51800'.to_i.to_s, name: 'Otras Acciones y Participaciones de Capital en el Exterior'.strip.upcase }, 
{ origin_number: ' 165'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 52100'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo a la Administracion Central'.strip.upcase }, 
{ origin_number: ' 166'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 52200'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo a Instituciones Publicas Descentralizadas'.strip.upcase }, 
{ origin_number: ' 167'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 52400'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo a Prefecturas'.strip.upcase }, 
{ origin_number: ' 168'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 52500'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo a Municipios'.strip.upcase }, 
{ origin_number: ' 169'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 52600'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo a Instituciones de Seguridad Social'.strip.upcase }, 
{ origin_number: ' 170'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 52700'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo a Empresas Publicas No Financieras Nacionales'.strip.upcase }, 
{ origin_number: ' 171'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 52800'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo a Empresas Publicas No Financieras de las Prefecturas'.strip.upcase }, 
{ origin_number: ' 172'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 52900'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo a Empresas Publicas No Financieras Municipales'.strip.upcase }, 
{ origin_number: ' 173'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 53100'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo a la Administracion Central'.strip.upcase }, 
{ origin_number: ' 174'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 53200'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo a Instituciones Publicas Descentralizadas'.strip.upcase }, 
{ origin_number: ' 175'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 53400'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo a Prefecturas'.strip.upcase }, 
{ origin_number: ' 176'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 53500'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo a Municipios'.strip.upcase }, 
{ origin_number: ' 177'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 53600'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo a Instituciones de Seguridad Social'.strip.upcase }, 
{ origin_number: ' 178'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 53700'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo a Empresas Publicas No Financieras Nacionales'.strip.upcase }, 
{ origin_number: ' 179'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 53800'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo a Empresas Publicas No Financieras de las Prefecturas'.strip.upcase }, 
{ origin_number: ' 180'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 53900'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo a Empresas Publicas No Financieras Municipales'.strip.upcase }, 
{ origin_number: ' 181'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 54100'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo a Instituciones Publicas Financieras No Bancarias'.strip.upcase }, 
{ origin_number: ' 182'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 54200'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo a Instituciones Publicas Financieras Bancarias'.strip.upcase }, 
{ origin_number: ' 183'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 54300'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo al Sector Privado'.strip.upcase }, 
{ origin_number: ' 184'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 54400'.to_i.to_s, name: 'Concesion de Prestamos a Corto Plazo al Exterior'.strip.upcase }, 
{ origin_number: ' 185'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 54500'.to_i.to_s, name: 'Colocaciones de Fondos en Fideicomiso'.strip.upcase }, 
{ origin_number: ' 186'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 54600'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo a Instituciones Publicas Financieras No Bancarias'.strip.upcase }, 
{ origin_number: ' 187'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 54700'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo a Instituciones Publicas Financieras Bancarias'.strip.upcase }, 
{ origin_number: ' 188'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 54800'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo al Sector Privado'.strip.upcase }, 
{ origin_number: ' 189'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 54900'.to_i.to_s, name: 'Concesion de Prestamos a Largo Plazo al Exterior'.strip.upcase }, 
{ origin_number: ' 190'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 55100'.to_i.to_s, name: 'Titulos y Valores a Corto Plazo'.strip.upcase }, 
{ origin_number: ' 191'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 55110'.to_i.to_s, name: 'Letras del Tesoro'.strip.upcase }, 
{ origin_number: ' 192'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 55120'.to_i.to_s, name: 'Bonos del Tesoro'.strip.upcase }, 
{ origin_number: ' 193'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 55130'.to_i.to_s, name: 'Otros'.strip.upcase }, 
{ origin_number: ' 194'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 55200'.to_i.to_s, name: 'Titulos y Valores a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 195'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 55210'.to_i.to_s, name: 'Letras del Tesoro'.strip.upcase }, 
{ origin_number: ' 196'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 55220'.to_i.to_s, name: 'Bonos del Tesoro'.strip.upcase }, 
{ origin_number: ' 197'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 55230'.to_i.to_s, name: 'Otros'.strip.upcase }, 
{ origin_number: ' 198'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 57100'.to_i.to_s, name: 'Incremento de Caja y Bancos'.strip.upcase }, 
{ origin_number: ' 199'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 57200'.to_i.to_s, name: 'Incremento de Inversiones Temporales'.strip.upcase }, 
{ origin_number: ' 200'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 58100'.to_i.to_s, name: 'Incremento de Cuentas por Cobrar a Corto Plazo'.strip.upcase }, 
{ origin_number: '201'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 58200'.to_i.to_s, name: 'Incremento de Documentos por Cobrar y Otros Activos Financieros a Corto Plazo'.strip.upcase }, 
{ origin_number: ' 202'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 58300'.to_i.to_s, name: 'Incremento de Cuentas por Cobrar a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 203'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 58400'.to_i.to_s, name: 'Incremento de Documentos por Cobrar y Otros Activos Financieros a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 204'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 59100'.to_i.to_s, name: 'Afectaciones al Tesoro General de la Nacion'.strip.upcase }, 
{ origin_number: ' 205'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 61100'.to_i.to_s, name: 'Amortizacion de la Deuda Publica Interna a Corto Plazo'.strip.upcase }, 
{ origin_number: ' 206'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 61200'.to_i.to_s, name: 'Intereses de la Deuda Publica Interna a Corto Plazo'.strip.upcase }, 
{ origin_number: ' 207'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 61300'.to_i.to_s, name: 'Comisiones y Otros Gastos de la Deuda Publica Interna a Corto Plazo'.strip.upcase }, 
{ origin_number: ' 208'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 61400'.to_i.to_s, name: 'Intereses por Mora y Multas de la Deuda Publica Interna a Corto Plazo'.strip.upcase }, 
{ origin_number: ' 209'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 61600'.to_i.to_s, name: 'Amortizacion de la Deuda Publica Interna a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 210'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 61700'.to_i.to_s, name: 'Intereses de la Deuda Publica Interna a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 211'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 61800'.to_i.to_s, name: 'Comisiones y Otros Gastos de la Deuda Publica Interna a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 212'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 61900'.to_i.to_s, name: 'Intereses por Mora y Multas de la Deuda Publica Interna a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 213'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 62100'.to_i.to_s, name: 'Amortizacion de la Deuda Publica Externa a Corto Plazo'.strip.upcase }, 
{ origin_number: ' 214'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 62200'.to_i.to_s, name: 'Intereses de la Deuda Publica Externa a Corto Plazo'.strip.upcase }, 
{ origin_number: ' 215'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 62300'.to_i.to_s, name: 'Comisiones y Otros Gastos de la Deuda Publica Externa a Corto Plazo'.strip.upcase }, 
{ origin_number: ' 216'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 62400'.to_i.to_s, name: 'Intereses por Mora y Multas de la Deuda Publica Externa a Corto Plazo'.strip.upcase }, 
{ origin_number: ' 217'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 62600'.to_i.to_s, name: 'Amortizacion de la Deuda Publica Externa a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 218'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 62700'.to_i.to_s, name: 'Intereses de la Deuda Publica Externa a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 219'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 62800'.to_i.to_s, name: 'Comisiones y Otros Gastos de la Deuda Publica Externa a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 220'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 62900'.to_i.to_s, name: 'Intereses por Mora y Multas de la Deuda Publica Externa a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 221'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 63100'.to_i.to_s, name: 'Disminucion de Cuentas por Pagar a Corto Plazo por Deudas Comerciales'.strip.upcase }, 
{ origin_number: ' 222'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 63200'.to_i.to_s, name: 'Disminucion de Cuentas por Pagar a Corto Plazo con Contratistas'.strip.upcase }, 
{ origin_number: ' 223'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 63300'.to_i.to_s, name: 'Disminucion de Cuentas por Pagar a Corto Plazo por Sueldos y Jornales'.strip.upcase }, 
{ origin_number: ' 224'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 63400'.to_i.to_s, name: 'Disminucion de Cuentas por Pagar a Corto Plazo por Aportes Patronales'.strip.upcase }, 
{ origin_number: ' 225'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 63500'.to_i.to_s, name: 'Disminucion de Cuentas por Pagar a Corto Plazo por Retenciones'.strip.upcase }, 
{ origin_number: ' 226'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 63600'.to_i.to_s, name: 'Disminucion de Cuentas por Pagar a Corto Plazo por Impuestos, Regalias y Tasas'.strip.upcase }, 
{ origin_number: ' 227'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 63700'.to_i.to_s, name: 'Disminucion de Cuentas por Pagar a Corto Plazo por Jubilaciones y Pensiones'.strip.upcase }, 
{ origin_number: ' 228'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 63800'.to_i.to_s, name: 'Disminucion de Cuentas por Pagar a Corto Plazo por Intereses'.strip.upcase }, 
{ origin_number: ' 229'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 63900'.to_i.to_s, name: 'Disminucion de Otros Pasivos y Otras Cuentas por Pagar a Corto Plazo'.strip.upcase }, 
{ origin_number: ' 230'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 64100'.to_i.to_s, name: 'Disminucion de Cuentas por Pagar a Largo Plazo por Deudas Comerciales'.strip.upcase }, 
{ origin_number: ' 231'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 64200'.to_i.to_s, name: 'Disminucion de Otras Cuentas por Pagar a Largo Plazo'.strip.upcase }, 
{ origin_number: ' 232'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 65100'.to_i.to_s, name: 'Gastos Devengados No Pagados por Servicios Personales'.strip.upcase }, 
{ origin_number: ' 233'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 65200'.to_i.to_s, name: 'Gastos Deveng.No Pagados por Serv.No Person.,Mat.y Suministros,Activos Reales y Financ.y Serv.Deuda'.strip.upcase }, 
{ origin_number: ' 234'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 65300'.to_i.to_s, name: 'Gastos Devengados No Pagados por Transferencias'.strip.upcase }, 
{ origin_number: ' 235'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 65400'.to_i.to_s, name: 'Gastos Devengados No Pagados por Retenciones'.strip.upcase }, 
{ origin_number: ' 236'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 65900'.to_i.to_s, name: 'Otros Gastos Devengados No Pagados'.strip.upcase }, 
{ origin_number: ' 237'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 66100'.to_i.to_s, name: 'Gastos Devengados No Pagados por Servicios Personales'.strip.upcase }, 
{ origin_number: ' 238'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 66200'.to_i.to_s, name: 'Gastos Devengados No Pagados por Servicios No Pers., Mat. y Sumin., Act.Reales y Fin.y Serv.Deuda'.strip.upcase }, 
{ origin_number: ' 239'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 66300'.to_i.to_s, name: 'Gastos Devengados No Pagados por Transferencias'.strip.upcase }, 
{ origin_number: ' 240'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 66400'.to_i.to_s, name: 'Gastos Devengados No Pagados por Retenciones'.strip.upcase }, 
{ origin_number: ' 241'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 66900'.to_i.to_s, name: 'Otros Gastos No Pagados'.strip.upcase }, 
{ origin_number: ' 242'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 67100'.to_i.to_s, name: 'Obligaciones por Afectaciones al Tesoro General de la Nacion'.strip.upcase }, 
{ origin_number: ' 243'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 68200'.to_i.to_s, name: 'Pago de Beneficios Sociales'.strip.upcase }, 
{ origin_number: ' 244'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 69100'.to_i.to_s, name: 'Devolucion de Fondos en Fideicomiso de Corto Plazo'.strip.upcase }, 
{ origin_number: ' 245'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 69200'.to_i.to_s, name: 'Devolucion de Fondos en Fideicomiso de Largo Plazo'.strip.upcase }, 
{ origin_number: ' 246'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 71100'.to_i.to_s, name: 'Pensiones y Jubilaciones'.strip.upcase }, 
{ origin_number: ' 247'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 71200'.to_i.to_s, name: 'Becas'.strip.upcase }, 
{ origin_number: ' 248'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 71300'.to_i.to_s, name: 'Donaciones, Ayudas Sociales y Premios a Personas'.strip.upcase }, 
{ origin_number: ' 249'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 71500'.to_i.to_s, name: 'Transferencias a Fondos de Pensiones de Capitalizacion'.strip.upcase }, 
{ origin_number: ' 250'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 71600'.to_i.to_s, name: 'Subsidios y Donaciones a Instituciones Privadas sin Fines de Lucro'.strip.upcase }, 
{ origin_number: '251'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 71700'.to_i.to_s, name: 'Subvenciones Economicas a Empresas'.strip.upcase }, 
{ origin_number: ' 252'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 71800'.to_i.to_s, name: 'Pensiones Vitalicias'.strip.upcase }, 
{ origin_number: ' 253'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 72200'.to_i.to_s, name: 'Transferencias Corrientes a Instituciones Publicas Descentralizadas por Participacion en Tributos'.strip.upcase }, 
{ origin_number: ' 254'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 72400'.to_i.to_s, name: 'Transferencias Corrientes a Prefecturas por Participacion en Tributos'.strip.upcase }, 
{ origin_number: ' 255'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 72500'.to_i.to_s, name: 'Transferencias Corrientes a Municipios por Participacion en Tributos'.strip.upcase }, 
{ origin_number: ' 256'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 73100'.to_i.to_s, name: 'Transferencias Corrientes a la Administracion Central por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 257'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 73200'.to_i.to_s, name: 'Transferencias Corrientes a Instituciones Publicas Descentralizadas por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 258'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 73300'.to_i.to_s, name: 'Transferencias Corrientes del Fondo Solidario Nacional'.strip.upcase }, 
{ origin_number: ' 259'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 73400'.to_i.to_s, name: 'Transferencias Corrientes a Prefecturas por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 260'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 73500'.to_i.to_s, name: 'Transferencias Corrientes a Municipios por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 261'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 73600'.to_i.to_s, name: 'Transferencias Corrientes a Instituciones de Seguridad Social por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 262'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 73700'.to_i.to_s, name: 'Transferencias Corrientes a Empresas Publicas no Financieras Nacionales por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 263'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 73800'.to_i.to_s, name: 'Transferencias Corrientes a Empresas Publicas no Financieras de las Prefecturas por Subs. o Subvenc.'.strip.upcase }, 
{ origin_number: ' 264'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 73900'.to_i.to_s, name: 'Transferencias Corrientes a Empresas Publicas no Financieras Municipales por Subsidios o Subvenc.'.strip.upcase }, 
{ origin_number: ' 265'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 74100'.to_i.to_s, name: 'Transferencias Corrientes a Instituciones Publicas Financieras No Bancarias'.strip.upcase }, 
{ origin_number: ' 266'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 74200'.to_i.to_s, name: 'Transferencias Corrientes a Instituciones Publicas Financieras Bancarias'.strip.upcase }, 
{ origin_number: ' 267'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 75100'.to_i.to_s, name: 'Transferencias de Capital a Personas'.strip.upcase }, 
{ origin_number: ' 268'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 75200'.to_i.to_s, name: 'Transferencias de Capital a Instituciones Privadas sin Fines de Lucro'.strip.upcase }, 
{ origin_number: ' 269'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 75210'.to_i.to_s, name: 'A Instituciones Privadas sin Fines de Lucro'.strip.upcase }, 
{ origin_number: ' 270'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 75300'.to_i.to_s, name: 'Transferencias de Capital a Empresas Privadas'.strip.upcase }, 
{ origin_number: ' 271'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 77100'.to_i.to_s, name: 'Transferencias de Capital a la Administracion Central por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 272'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 77200'.to_i.to_s, name: 'Transferencias de Capital a Instituciones Publicas Descentralizadas por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 273'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 77400'.to_i.to_s, name: 'Transferencias de Capital a Prefecturas por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 274'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 77500'.to_i.to_s, name: 'Transferencias de Capital a Municipios por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 275'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 77600'.to_i.to_s, name: 'Transferencias de Capital a Instituciones de Seguridad Social por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 276'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 77700'.to_i.to_s, name: 'Transferencias de Capital a Empresas Publicas no Financieras Nacionales por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 277'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 77800'.to_i.to_s, name: 'Transferencias de Capital a Empresas Publicas No Financieras de las Prefecturas por Subs. o Subvenc.'.strip.upcase }, 
{ origin_number: ' 278'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 77900'.to_i.to_s, name: 'Transferencias de Capital a Empresas Pub. No Financieras Municipales por Subsidios o Subvenciones'.strip.upcase }, 
{ origin_number: ' 279'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 78100'.to_i.to_s, name: 'Transferencias de Capital a Instituciones Publicas Financieras No Bancarias'.strip.upcase }, 
{ origin_number: ' 280'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 78200'.to_i.to_s, name: 'Transferencias de Capital a Instituciones Publicas Financieras Bancarias'.strip.upcase }, 
{ origin_number: ' 281'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 79100'.to_i.to_s, name: 'Transferencias Corrientes a Gobiernos Extranjeros y Organismos Internacionales por Cuotas Regulares'.strip.upcase }, 
{ origin_number: ' 282'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 79200'.to_i.to_s, name: 'Transferencias Corrientes a Gob. Extranjeros y Org. Internacionales por Cuotas Extraordinarias'.strip.upcase }, 
{ origin_number: ' 283'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 79300'.to_i.to_s, name: 'Otras Transferencias Corrientes al Exterior'.strip.upcase }, 
{ origin_number: ' 284'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 79400'.to_i.to_s, name: 'Transferencias de Capital al Exterior'.strip.upcase }, 
{ origin_number: ' 285'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81100'.to_i.to_s, name: 'Impuestos sobre las Utilidades de las Empresas'.strip.upcase }, 
{ origin_number: ' 286'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81200'.to_i.to_s, name: 'Impuesto a las Transacciones'.strip.upcase }, 
{ origin_number: ' 287'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81300'.to_i.to_s, name: 'Impuesto al Valor Agregado Mercado Interno'.strip.upcase }, 
{ origin_number: ' 288'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81400'.to_i.to_s, name: 'Impuesto al Valor Agregado Importaciones'.strip.upcase }, 
{ origin_number: ' 289'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81500'.to_i.to_s, name: 'Impuesto a los Consumos Especificos Mercado Interno'.strip.upcase }, 
{ origin_number: ' 290'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81600'.to_i.to_s, name: 'Impuesto a los Consumos Especificos Importaciones'.strip.upcase }, 
{ origin_number: ' 291'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81700'.to_i.to_s, name: 'Impuesto Especial a los Hidrocarburos y sus Derivados Mercado Interno'.strip.upcase }, 
{ origin_number: ' 292'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81800'.to_i.to_s, name: 'Impuesto Especial a los Hidrocarburos y sus Derivados Importacion'.strip.upcase }, 
{ origin_number: ' 293'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81900'.to_i.to_s, name: 'Otros Impuestos'.strip.upcase }, 
{ origin_number: ' 294'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81910'.to_i.to_s, name: 'Impuesto a Viajes al Exterior'.strip.upcase }, 
{ origin_number: ' 295'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81920'.to_i.to_s, name: 'Regimen Tributario Simplificado'.strip.upcase }, 
{ origin_number: ' 296'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81930'.to_i.to_s, name: 'Regimen Tributario Integrado'.strip.upcase }, 
{ origin_number: ' 297'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81950'.to_i.to_s, name: 'Transmision Gratuita de Bienes'.strip.upcase }, 
{ origin_number: ' 298'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81960'.to_i.to_s, name: 'Impuesto a las Transacciones Financieras - ITF'.strip.upcase }, 
{ origin_number: ' 299'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 81990'.to_i.to_s, name: 'Otros'.strip.upcase }, 
{ origin_number: ' 300'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 82100'.to_i.to_s, name: 'Gravamen Aduanero Consolidado'.strip.upcase }, 
{ origin_number: ' 301'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 83100'.to_i.to_s, name: 'Impuesto a la Propiedad de Bienes'.strip.upcase }, 
{ origin_number: ' 302'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 83110'.to_i.to_s, name: 'Inmuebles'.strip.upcase }, 
{ origin_number: ' 303'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 83120'.to_i.to_s, name: 'Vehiculos Automotores'.strip.upcase }, 
{ origin_number: ' 304'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 83200'.to_i.to_s, name: 'Impuesto a las Transferencias'.strip.upcase }, 
{ origin_number: ' 305'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 83210'.to_i.to_s, name: 'Inmuebles'.strip.upcase }, 
{ origin_number: ' 306'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 83220'.to_i.to_s, name: 'Vehiculos Automotores'.strip.upcase }, 
{ origin_number: ' 307'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 84100'.to_i.to_s, name: 'Regalias Mineras'.strip.upcase }, 
{ origin_number: ' 308'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 84200'.to_i.to_s, name: 'Regalias por Hidrocarburos'.strip.upcase }, 
{ origin_number: ' 309'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 84210'.to_i.to_s, name: '19% Sobre Produccion de Hidrocarburos'.strip.upcase }, 
{ origin_number: ' 310'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 84220'.to_i.to_s, name: '13% Regalia Nacional Complementaria'.strip.upcase }, 
{ origin_number: ' 311'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 84230'.to_i.to_s, name: '6 % Participacion YPFB'.strip.upcase }, 
{ origin_number: ' 312'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 84240'.to_i.to_s, name: '11 % Sobre Produccion por Regalias Departamentales'.strip.upcase }, 
{ origin_number: ' 313'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 84250'.to_i.to_s, name: '1 % Sobre Produccion por Regalias Departamentales'.strip.upcase }, 
{ origin_number: ' 314'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 84300'.to_i.to_s, name: 'Regalias Agropecuarias'.strip.upcase }, 
{ origin_number: ' 315'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 84900'.to_i.to_s, name: 'Otras Regalias'.strip.upcase }, 
{ origin_number: ' 316'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 85100'.to_i.to_s, name: 'Tasas'.strip.upcase }, 
{ origin_number: ' 317'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 85200'.to_i.to_s, name: 'Derechos'.strip.upcase }, 
{ origin_number: ' 318'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 85300'.to_i.to_s, name: 'Contribuciones por Mejoras'.strip.upcase }, 
{ origin_number: ' 319'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 85400'.to_i.to_s, name: 'Multas'.strip.upcase }, 
{ origin_number: ' 320'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 85500'.to_i.to_s, name: 'Intereses Penales'.strip.upcase }, 
{ origin_number: ' 321'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 85900'.to_i.to_s, name: 'Otros'.strip.upcase }, 
{ origin_number: ' 322'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 86100'.to_i.to_s, name: 'Patentes'.strip.upcase }, 
{ origin_number: ' 323'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 91100'.to_i.to_s, name: 'Intereses de Instituciones Publicas Financieras No Bancarias'.strip.upcase }, 
{ origin_number: ' 324'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 91200'.to_i.to_s, name: 'Intereses de Instituciones Publicas Financieras Bancarias'.strip.upcase }, 
{ origin_number: ' 325'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 94200'.to_i.to_s, name: 'Desahucio'.strip.upcase }, 
{ origin_number: ' 326'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 94300'.to_i.to_s, name: 'Otros Beneficios Sociales'.strip.upcase }, 
{ origin_number: ' 327'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 96100'.to_i.to_s, name: 'Perdidas en Operaciones Cambiarias'.strip.upcase }, 
{ origin_number: ' 328'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 96200'.to_i.to_s, name: 'Devoluciones'.strip.upcase }, 
{ origin_number: ' 329'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 96900'.to_i.to_s, name: 'Otras Perdidas'.strip.upcase }, 
{ origin_number: ' 330'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 97100'.to_i.to_s, name: 'Comisiones por Ventas'.strip.upcase }, 
{ origin_number: ' 331'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 97200'.to_i.to_s, name: 'Bonificaciones por Ventas'.strip.upcase }, 
{ origin_number: ' 332'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 98100'.to_i.to_s, name: 'Del Sector Publico'.strip.upcase }, 
{ origin_number: ' 333'.gsub(/[^0-9]/, '').to_i.to_s, item_number:' 98200'.to_i.to_s, name: 'Del Sector Privado'.strip.upcase }, 
{ origin_number: ''.gsub(/[^0-9]/, '').to_i.to_s, item_number:' '.to_i.to_s, name: ''.strip.upcase }])

	end



end
