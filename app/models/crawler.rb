class Crawler < ActiveRecord::Base


	def self.crawl(year)

		a = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
		}


		from_date = Date.new(year, 12, 28)
		to_date   = Date.new(year, 12, 31)

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

		while(1)
			puts "proceso" + init_range.to_s + ".." + end_range.to_s
			crawl_forms400_proc(init_range, end_range)
		end

	end

	def self.crawl_forms400_proc(init_range, end_range)

		a = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
		}

		contract_forms = ContractForm.where("contract_forms.name = 'FORM 400'
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


			#contract_form = ContractForm.find(1)

			c = Contract.find(contract_form.contract_id)
			headers = {"Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
					"Cache-Control"	=> "max-age=0",
					"User-Agent" =>	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.5.17 (KHTML, like Gecko) Version/8.0.5 Safari/600.5.17"}

			
			puts contract_form.link
			puts init_range.to_s + ".." + end_range.to_s
			puts contract_form.id


			a.pre_connect_hooks << Proc.new { sleep 0.05 }
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



end
