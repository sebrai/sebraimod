
-- you can have shared helper functions
function shakecard(self) --visually shake a card
    G.E_MANAGER:add_event(Event({
        func = function()
            self:juice_up(0.5, 0.5)
            return true
        end
    }))
end

function return_JokerValues() -- not used, just here to demonstrate how you could return values from a joker
    if context.joker_main and context.cardarea == G.jokers then
        return {
            chips = card.ability.extra.chips,       -- these are the 3 possible scoring effects any joker can return.
            mult = card.ability.extra.mult,         -- adds mult (+)
            x_mult = card.ability.extra.x_mult,     -- multiplies existing mult (*)
            card = self,                            -- under which card to show the message
            colour = G.C.CHIPS,                     -- colour of the message, Balatro has some predefined colours, (Balatro/globals.lua)
            message = localize('k_upgrade_ex'),     -- this is the message that will be shown under the card when it triggers.
            extra = { focus = self, message = localize('k_upgrade_ex') }, -- another way to show messages, not sure what's the difference.
        }
    end
end

-- returns total chips the card *should* contribute according to base + enhancement + edition
function get_total_card_chips(card)
    -- 1) get a sensible base chip value (try a few likely fields)
    local base = 0
    base = card.chips or base

    -- some cards store base info under card.base or card.base.nominal
    if base == 0 and card.base and card.base.nominal then
        -- nominal may be "2".."10","J","Q","K","Ace" etc.
        local nom = card.base.nominal
        if type(nom) == "number" then
            base = nom
        else
            if nom == "Ace" or nom == "A" then
                base = 11
            elseif nom == "J" or nom == "Q" or nom == "K" then
                base = 10
            else
                local n = tonumber(nom)
                if n then base = n end
            end
        end
    end

    -- fallback if still zero: some cards put a default chips value under card.ability.chips
    if base == 0 and card.ability and card.ability.chips then
        base = card.ability.chips
    end

    -- 2) enhancement bonuses (common Balatro mapping)
    if card.ability and card.ability.name then
        local name = card.ability.name
        if name == "Bonus" then
            base = base + 30        -- Bonus card +30 chips (wiki)
        elseif name == "Stone" then
            base = base + 50        -- Stone sets +50 (wiki)
        -- other enhancements that affect chips can be added here
        end
    end

    -- 3) edition bonuses (check typical edition flags)
    if card.edition then
        -- edition may be a table of flags like { foil=true, gold=true, holographic=true }
        if card.edition.foil then
            base = base + 50        -- Foil +50 chips (wiki)
        end
        
    end

    -- 4) mods / jokers may have placed an explicit numeric contribution in ability.extra
    if card.ability and card.ability.extra and type(card.ability.extra.chips) == "number" then
        base = base + card.ability.extra.chips
    end

    return base
end


SMODS.Atlas({
    key = "sample_wee",
    path = "j_sample_wee.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_obelisk",
    path = "j_sample_obelisk.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_specifichand",
    path = "j_sample_specifichand.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_money",
    path = "j_sample_money.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_roomba",
    path = "j_sample_roomba.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_drunk_juggler",
    path = "j_sample_drunk_juggler.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_hackerman",
    path = "j_sample_hackerman.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_baroness",
    path = "j_sample_baroness.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_rarebaseballcard",
    path = "j_sample_rarebaseballcard.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_multieffect",
    path = "j_sample_multieffect.png",
    px = 71,
    py = 95
})
SMODS.Atlas({
    key ="seb_double_trouble",
    path ="double_trouble.png",
    px = 71,
    py = 95
})
SMODS.Atlas({
    key = "seb_switcheroo",
    path ="switcheroo.png",
    px = 71,
    py =95,
})
SMODS.Atlas({
    key = "seb_jimbo_dot",
    path = "jimbo_dot.png",
    px = 71,
    py = 95,
})
SMODS.Atlas({
    key = "seb_funny_joker",
    path = "funny_joker.png",
    px = 71,
    py = 95,
})
SMODS.Atlas({
    key = 'seb_red_joker',
    path = 'red_joker.png',
    px = 71,
    py = 95,
})
SMODS.Atlas({
    key = 'seb_loker_pot',
    path = 'money_pot.png',
    px =71,
    py = 95,
})
SMODS.Joker{
    key = "double_trouble",                                  --name used by the joker.    
    config = { extra = { chips = 1, x_chip = 1.2 } },    --variables used for abilities and effects.
    pos = { x = 0, y = 0 },                              --pos in spritesheet 0,0 for single sprites or the first sprite in the spritesheet.
    rarity = 2,                                          --rarity 1=common, 2=uncommen, 3=rare, 4=legendary
    cost = 4,                                            --cost to buy the joker in shops.
    blueprint_compat=true,                               --does joker work with blueprint.
    eternal_compat=true,                                 --can joker be eternal.
    unlocked = true,                                     --is joker unlocked by default.
    discovered = true,                                   --is joker discovered by default.
    effect=nil,                                          --you can specify an effect here eg. 'Mult'
    soul_pos=nil,                                        --pos of a soul sprite.
    atlas = 'double_trouble',                                --atlas name, single sprites are deprecated.

    calculate = function(self,card,context)              --define calculate functions here
        if context.individual and context.cardarea == G.play then -- if we are in card scoring phase, and we are on individual cards
            if not context.blueprint then -- blueprint/brainstorm don't get to add chips to themselves
                if context.other_card:get_id() == 2 then -- played card is a 2 by rank
                    card.ability.extra.chips = card.ability.extra.chips * card.ability.extra.x_chip -- add configurable amount of chips to joker
                    return {                             -- shows a message under the specified card (card) when it triggers, k_upgrade_ex is a key in the localization files of Balatro
                        extra = {focus = card, message = localize('k_upgrade_ex')},
                        card = card,
                        colour = G.C.CHIPS
                    }
                end
            end
        end
        if context.joker_main and context.cardarea == G.jokers then
            return {                                     -- returns total chips from joker to be used in scoring, no need to show message in joker_main phase, game does it for us.
                chips = card.ability.extra.chips, 
                colour = G.C.CHIPS
            }
        end
    end,

    loc_vars = function(self, info_queue, card)          --defines variables to use in the UI. you can use #1# for example to show the chips variable
        return { vars = { card.ability.extra.chips, card.ability.extra.x_chip }, key = self.key }
    end
}
SMODS.Joker{
    key = "switcheroo",
    config ={extra ={do_i_put_stuff = "hello!", chips = 0, mult =0}},
    pos = {x=0 , y=0},
    rarity = 3,
    cost = 8,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    effect = nil,
    soul_pos = nil,
    atlas = 'switcheroo',

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local played = context.other_card


            local base_mult  = played.mult  or played.ability.mult  or 0
            local base_chips = get_total_card_chips(played)
            if played.edition then
                if played.edition.holographic then
                        base_mult = base_mult + 10
                end
            end
            return {
                chips = base_mult - base_chips,
                mult  = base_chips - base_mult
            }
        end
    end,

    loc_vars = function(self,info_queue,card)
        return {vars = {card.ability.extra.do_i_put_stuff}, key =self.key}
    end
}

SMODS.Joker{
    key = "jimbo_dot",
    config = {extra={mult = 4, crazymult=1.3} },
    pos = { x = 0 , y = 0},
    rarity = 3,
    cost = 10,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    effect = nil,
    atlas= "jimbo_dot",
    soul_pos = nil,

    calculate = function(self,card,context)
        if context.joker_main and context.cardarea == G.jokers  then
            if math.random(1,4) == 1 then
                return{
                mult = card.ability.extra.crazymult 
                }
            end
            return{
                mult = card.ability.extra.mult
            }
        end
        if context.ante_change then
            card.ability.extra.crazymult = card.ability.extra.crazymult ^ 2
        end
    end,
    loc_vars = function ( self,info_queue,card )
         return {vars = {card.ability.extra.mult,card.ability.extra.crazymult}, key =self.key}
    end
}
SMODS.Joker{
key = "funny_joker",
config ={extra={x_mult = 1.5}},
pos = {x=0,y=0},
rarity = 1,
cost = 3,
blueprint_compat = true,
eternal_compat = true,
unlocked = true,
discovered = true,
effect = nil,
soul_pos = nil,
atlas = 'funny_joker',

calculate = function ( self,card,context )
    if context.joker_main and context.cardarea == G.jokers  then
        return {
            x_mult = card.ability.extra.x_mult
        }
    end

end,
loc_vars = function ( self,info_queue,card )
    return {vars = {card.ability.extra.x_mult},key = self.key}
end

}

SMODS.Joker{
key = "red_joker",
config ={extra={mult = 4,chips= 23.2}},
pos = {x=0,y=0},
rarity = 1,
cost = 3,
blueprint_compat = true,
eternal_compat = true,
unlocked = true,
discovered = true,
effect = nil,
soul_pos = nil,
atlas = 'red_joker',

calculate = function ( self,card,context )
    if context.joker_main and context.cardarea == G.jokers  then
        return {
            mult = card.ability.extra.mult,
            chips = card.ability.extra.chips
        }
    end

end,
loc_vars = function ( self,info_queue,card )
    return {vars = {card.ability.extra.mult,card.ability.extra.chips},key = self.key}
end

}

SMODS.Joker{
    key = "sample_obelisk",
    config = { extra = { x_mult = 0.1 } },
    pos = { x = 0, y = 0 },
    rarity = 3,
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    effect = nil,
    atlas = 'sample_obelisk',
    soul_pos = nil,

    calculate = function(self, card, context)
        if context.joker_main and context.cardarea == G.jokers and context.scoring_name then
            local current_hand_times = (G.GAME.hands[context.scoring_name].played or 0) -- how many times has the player played the current type of hand. (pair, two pair. etc..)
            local current_xmult = 1 + (current_hand_times * card.ability.extra.x_mult)
            
            return {
                message = localize{type='variable',key='a_xmult',vars={current_xmult}},
                colour = G.C.RED,
                x_mult = current_xmult
            }

            -- you could also apply it to the joker, to do it like the sample wee, but then you'd have to reset the card and text every time the previewed hand changes.
        end
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult }, key = self.key }
    end
}

SMODS.Joker{
    key = "sample_specifichand",
    config = { extra = { poker_hand = "Five of a Kind", x_mult = 5 } },
    pos={ x = 0, y = 0 },
    rarity = 3,
    cost = 10,
    blueprint_compat=true,
    eternal_compat=true,
    unlocked = true,
    discovered = true,
    effect=nil,
    soul_pos=nil,
    atlas = 'sample_specifichand',

    calculate = function(self,card,context)
        if context.joker_main and context.cardarea == G.jokers then
            if context.scoring_name == card.ability.extra.poker_hand then
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
                    colour = G.C.RED,
                    x_mult = card.ability.x_mult
                }
            end
        end
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.poker_hand, card.ability.extra.x_mult }, key = self.key }
    end        
}

SMODS.Joker{
    key = "loker_pot",
    config={ },
    pos = { x = 0, y = 0 },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    effect = nil,
    atlas = 'loker_pot',
    soul_pos = nil,

    calculate = function(self, card, context)
        if context.end_of_round and not (context.individual or context.repetition) then --and not (context.individual or context.repetition) => make sure doesn't activate on every card like gold cards.
            ease_dollars(G.GAME.round_resets.blind_ante^2) -- ease_dollars adds or removes provided amount of money. (-5 would remove 5 for example)
        end
    end,
    loc_vars = function(self, info_queue, card)
        return { }
    end
}

SMODS.Joker{
    key = "sample_roomba",
    config={ },
    pos = { x = 0, y = 0 },
    rarity = 2,
    cost = 4,
    blueprint_compat = true,
    eternal_compat = false,
    unlocked = true,
    discovered = true,
    effect = nil,
    atlas = 'sample_roomba',
    soul_pos = nil,

        calculate = function(self, card, context)
        if context.end_of_round and not (context.individual or context.repetition) then
            local cleanable_jokers = {}

            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= self then -- if joker is not itself 
                    cleanable_jokers[#cleanable_jokers+1] = G.jokers.cards[i] -- add all other jokers into a array
                end
            end

            local joker_to_clean = #cleanable_jokers > 0 and pseudorandom_element(cleanable_jokers, pseudoseed('clean')) or nil -- pick a random valid joker, or null if no valid jokers

            if joker_to_clean then -- if we have a valid joker we can bump into
                shakecard(joker_to_clean) -- simulate bumping into a card
                if(joker_to_clean.edition) then --if joker has an edition
                    if not joker_to_clean.edition.negative then --if joker is not negative
                        joker_to_clean:set_edition(nil) -- clean the joker from it's edition
                    end
                end
            end
        end
    end,

    loc_vars = function(self, info_queue, card)
        return { }
    end
}

SMODS.Joker{
    key = "sample_drunk_juggler",
    config = { d_size = 1 }, -- d_size  = discard size, h_size = hand size. (HOWEVER, you can't have both on 1 joker!)
    pos = { x = 0, y = 0 },
    rarity = 2,
    cost = 4,
    blueprint_compat = true,
    eternal_compat = false,
    unlocked = true,
    discovered = true,
    effect = nil,
    atlas = 'sample_drunk_juggler',
    soul_pos = nil,

    calculate = function(self, card, context)
        return nil
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.d_size, localize{type = 'name_text', key = 'tag_double', set = 'Tag'} } }
    end
}

SMODS.Joker{
    key = "sample_hackerman",
    config = { repetitions = 1 },
    pos = { x = 0, y = 0 },
    rarity = 2,
    cost = 4,
    blueprint_compat = true,
    eternal_compat = false,
    unlocked = true,
    discovered = true,
    effect = nil,
    atlas = 'sample_hackerman',
    soul_pos = nil,

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and (
            context.other_card:get_id() == 6 or 
            context.other_card:get_id() == 7 or 
            context.other_card:get_id() == 8 or 
            context.other_card:get_id() == 9) then
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.repetitions,
                card = self
            }
        end
    end,

    loc_vars = function(self, info_queue, card)
        return { }
    end
}

SMODS.Joker{
    key = "sample_baroness",
    config = { extra = { x_mult = 1.5 } },
    pos = { x = 0, y = 0 },
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    eternal_compat = false,
    unlocked = true,
    discovered = true,
    effect = nil,
    atlas = 'sample_baroness',
    soul_pos = nil,

    calculate = function(self, card, context)
        if not context.end_of_round then
            if context.cardarea == G.hand and context.individual and context.other_card:get_id() == 12 then
                if context.other_card.debuff then
                    return {
                        message = localize('k_debuffed'),
                        colour = G.C.RED,
                        card = self,
                    }
                else
                    return {
                        x_mult = card.ability.extra.x_mult,
                        card = self
                    }
                end
            end
        end
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult } }
    end
}

SMODS.Joker{
    key = "sample_rarebaseballcard",
    config = { extra = { x_mult = 2 } },
    pos = { x = 0, y = 0 },
    rarity = 2,
    cost = 8,
    blueprint_compat = true,
    eternal_compat = false,
    unlocked = true,
    discovered = true,
    effect = nil,
    atlas = 'sample_rarebaseballcard',
    soul_pos = nil,

    calculate = function(self, card, context)
        if not (context.individual or context.repetition) and context.other_joker and context.other_joker.config.center.rarity == 3 and self ~= context.other_joker then
            shakecard(context.other_joker)
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
                colour = G.C.RED,
                x_mult = card.ability.extra.x_mult
            }
        end
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult }, key = self.key}
    end
}

-- SMODS.Joker{
--     key = "sample_multieffect",
--     config = { extra = { chips = 10, mult = 10, x_mult = 2 } },
--     pos = { x = 0, y = 0 },
--     rarity = 2,
--     cost = 4,
--     blueprint_compat = true,
--     eternal_compat = false,
--     unlocked = true,
--     discovered = true,
--     effect = nil,
--     atlas = 'sample_multieffect',
--     soul_pos = nil,

--     calculate = function(self, card, context)
--         if context.individual and context.cardarea == G.play and context.other_card:get_id() == 10 then
--             return {
--                 chips = card.ability.extra.chips,
--                 mult = card.ability.extra.mult,
--                 x_mult = card.ability.extra.x_mult,
--                 card = self
--             }
--         end
--     end,

--     loc_vars = function(self, info_queue, card)
--         return { vars = { card.ability.extra.chips, card.ability.extra.mult }, key = self.key }
--     end
-- }