SELECT
	content_ability.Id ability_id,
	content_ability.AbilityTypeName ab_type,
	content_ability.FirstAbilityName ab_name_first,
	content_ability.SecondAbilityName ab_name_second
FROM
	iquizoo_content_db.content_ability;
