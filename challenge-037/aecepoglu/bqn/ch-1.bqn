# 1
DayOfWeek←{•BQN ¯1↓1⊑•SH "date"‿"-d"‿𝕩‿"+%u"}⟜('@'∾•Fmt) # 𝕩: date
date←•Import "datetime.bqn"
t0←date.From 2019‿1‿1‿0‿0‿0
w←1-˜DayOfWeek t0
(1+↕∘≠)⊸≍≠¨1↓(1⊑¨⊢)⊸⊔(5>7|w+↕∘≠)⊸/date.To¨t0+(24×3600)×↕365
