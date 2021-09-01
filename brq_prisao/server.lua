local Proxy = module('vrp','lib/Proxy')
local vRP = Proxy.getInterface('vRP')

vRP._prepare('suadb/prisao:insert', 'INSERT INTO suadp (user_id, tempo) VALUES (@user_id, @tempo)')
vRP._prepare('suadb/prisao:update', 'UPDATE suadb SET tempo=@tempo WHERE user_id=@user_id')
vRP._prepare('suadb/prisao:consult', 'SELECT * FROM suadb WHERE user_id = @user_id')
vRP._prepare('suadb/prisao:delete', 'DELETE FROM suadb WHERE user_id=@user_id')

prenderFunction = function(source)
    local user_id = vRP.getUserId(source)
    local hasPerm = vRP.hasPermission(user_id, 'policia.permissao')
    if hasPerm then
        local bandidoID = vRP.prompt(source, 'ID do bandido', '') -- ID DO BANDIDO COLOCADO PELO POLICIAL
        if tonumber( bandidoID ) then
            local tempo = vRP.prompt(source, 'Tempo de prisão (Max. 120)', '120') -- TEMPO QUE O BANDIDO PASSA NA CADEIA
            if tonumber(tempo) then
                if tonumber(tempo) <= 120 and tonumber(tempo) > 0 then
                    local motivo = vRP.prompt(source, 'Motivo da prisão', 'Uso de máscara;') -- MOTIVO DA PRISÃO
                    if motivo ~= '' then
                        local linkfotobandido = vRP.prompt(source, 'Link da foto do bandido (*Precisa ser link)', '') -- LINK DA FOTO DO BANDIDO
                        if linkfotobandido:find('http') then
                            local identityBandido = vRP.getUserIdentity( tonumber(bandidoID) )
                            local nameBandido = identityBandido.name
                            local firstnameBandido = identityBandido.firstname
                            local identity = vRP.getUserIdentity( user_id )
                            local name = identity.name
                            local firstname = identity.firstname
                            sucesso(source,firstnameBandido .. ' ' .. nameBandido .. ' foi preso com sucesso por ' .. tempo .. ' meses!')
                            local valor = math.random(1000,2000)
                            vRP.giveBankMoney(user_id,valor)
                            sucesso(source,'Você recebeu R$' .. vRP.format(valor) .. ' de bonificanção pela prisão! Parabéns!')

                            local sourceBandido = vRP.getUserSource( tonumber(bandidoID) )
                            if sourceBandido then
                                TriggerClientEvent('brq:teleportarprisao', sourceBandido)
                                negado(sourceBandido, '<b>VOCÊ FOI PRESO</b><br><br><br><b>TEMPO</b>: ' .. tempo .. ' meses<br><b>MOTIVO</b>: ' .. motivo .. '<br><b>ID DO POLICIAL</b>: ' .. user_id)
                            end

                            local consult = vRP.query('brq/prisao:consult', {
                                user_id = tonumber(bandidoID)
                            })


                            if consult[1] then
                                vRP._execute('brq/prisao:update', {
                                    user_id = tonumber(bandidoID),
                                    tempo = tempo
                                })
                            else
                                vRP._execute('brq/prisao:insert', {
                                    user_id = tonumber(bandidoID),
                                    tempo = tempo
                                })
                            end
                            local message = "```prolog\n[INFORMAÇÕES DA PRISÃO]\n[TEMPO DE PRISÃO]: ".. tempo .."\n[MOTIVO]: ".. motivo .."\n[INFORMAÇÕES DO PRESO]\n[ID]: " .. bandidoID .. "\n[NOME]: " .. firstnameBandido .. ' ' .. nameBandido .. "\n[INFORMAÇÕES DO POLICIAL]\n[ID]: ".. user_id .."\n[NOME]: " .. firstname .. ' ' .. name .. "\n```\n" .. linkfotobandido
                            SendWebhookMessage( linkwebhook , message )

                        else
                            negado(source,'Você não colocou um link válido!')
                        end
                    else
                        negado(source,'Você não colocou motivo!')
                    end
                else
                    negado(source,'Você colocou o tempo abaixo de 0 ou acima de 120!')
                end
            else
                negado(source,'Você não colocou um número!')
            end
        else
            negado(source,'Você não colocou um número!')
        end
    else
        negado(source,'Sem permissão!')
    end
end

RegisterCommand('prisao', prenderFunction)

function negado(source,msg)
    TriggerClientEvent('Notify', source, 'negado', msg)
end

function sucesso(source,msg)
    TriggerClientEvent('Notify', source, 'sucesso', msg)
end

RegisterServerEvent('diminuirPena')
AddEventHandler('diminuirPena', function()
    local source = source
    local user_id = vRP.getUserId(source)
    local consult = vRP.query('brq/prisao:consult',{
        user_id = user_id
    })
    local tempo = consult[1].tempo
    if tempo == 1 then
        vRP.execute('brq/prisao:delete', {user_id = user_id})
        TriggerClientEvent('brq:setIsPresoFalse', source)
    else
        vRP.execute('brq/prisao:update', {user_id = user_id , tempo = tempo - 1})
        TriggerClientEvent('Notify', source, 'aviso', 'Sua pena ainda durará ' .. tempo - 1 .. ' meses!') 
    end
end)

RegisterServerEvent('fugindo')
AddEventHandler('fugindo', function()
    local source = source
    local user_id = vRP.getUserId(source)
    local consult = vRP.query('brq/prisao:consult',{
        user_id = user_id
    })
    local tempo = consult[1].tempo
    if tempo then
        vRP.execute('brq/prisao:update', {user_id = user_id , tempo = tempo + punicao})
        TriggerClientEvent('Notify', source, 'aviso', 'Sua pena foi aumentada para ' .. tempo + punicao .. ' meses, pois você estava fugindo!') 
    end
end)

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
    local consult = vRP.query('brq/prisao:consult',{
        user_id = user_id
    })
    if consult[1] then
        TriggerClientEvent('brq:teleportarprisao', source)
        TriggerClientEvent('Notify', source, 'aviso', 'Termine de pagar a pena! XD!')
    end
end)



function SendWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message, username = 'MORAES!', avatar_url = 'https://cdn.discordapp.com/avatars/721212568495980547/a_d2129bfe1afcb6e6b7001de90e4d6686.gif?size=2048'}), { ['Content-Type'] = 'application/json' })
	end
end


-- SendWebhookMessage('https://discord.com/api/webhooks/859612270648229918/QSQhOpkqbT-v55EzDto5pgVCyJ9DdRlIngesDY1GSFu__dj6DLJ5FJQweIc_ujdNJGJ2','Quero café isso aqui é uma porcaria, merda nenhuma! Quero café! https://cdn.discordapp.com/avatars/721212568495980547/a_d2129bfe1afcb6e6b7001de90e4d6686.gif?size=2048')