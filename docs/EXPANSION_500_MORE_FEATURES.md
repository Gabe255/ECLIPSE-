# ECLIPSE — 500 additional feature concepts

Added: 2026-11-22  
Target branch: `migration/pegasus-flutter-port`  
Companion backlog: `docs/EXPANSION_100_FEATURES.md`

These are 500 additional concepts, not claims of implementation. Compare each with the current app and existing backlog before coding; reuse existing functionality and remove duplicates.

## Engineering guardrails

- Preserve the existing emulator engine, ROM scanning, SAF permissions, game database, scraping and metadata cache, system art pipeline, launch routing, gamepad navigation, and Android app handoff.
- Extend existing providers, services, repositories, and models. Do not create duplicate backends.
- Only show facts, telemetry, compatibility, and session data when backed by real sources.
- Keep every user-facing string localized and every full-screen flow controller-accessible.
- Require explicit confirmation for destructive or privacy-sensitive actions.
- Keep AI, cloud, plugin, network, and community capabilities opt-in and permission-scoped.
- Ship tested slices, not a 500-feature mega-release.

## Library & browsing — 50 concepts

1. **Per-system landing-page tabs** — Add a focused, configurable experience with clear states and honest capability reporting.
2. **Recently imported shelf** — Add a focused, configurable experience with clear states and honest capability reporting.
3. **Unplayed-by-system shelf** — Add a focused, configurable experience with clear states and honest capability reporting.
4. **Short-session game shelf** — Add a focused, configurable experience with clear states and honest capability reporting.
5. **Long-form game shelf** — Add a focused, configurable experience with clear states and honest capability reporting.
6. **Alphabet jump rail** — Add a focused, configurable experience with clear states and honest capability reporting.
7. **Year-range browsing** — Add a focused, configurable experience with clear states and honest capability reporting.
8. **Publisher browsing** — Add a focused, configurable experience with clear states and honest capability reporting.
9. **Developer browsing** — Add a focused, configurable experience with clear states and honest capability reporting.
10. **Series browsing** — Add a focused, configurable experience with clear states and honest capability reporting.
11. **Genre intersection filters** — Add a focused, configurable experience with clear states and honest capability reporting.
12. **Region-aware browse groups** — Add a focused, configurable experience with clear states and honest capability reporting.
13. **Language tags** — Add a focused, configurable experience with clear states and honest capability reporting.
14. **Controller-required filter** — Add a focused, configurable experience with clear states and honest capability reporting.
15. **Touch-friendly filter** — Add a focused, configurable experience with clear states and honest capability reporting.
16. **Offline-ready filter** — Add a focused, configurable experience with clear states and honest capability reporting.
17. **File-format filter** — Add a focused, configurable experience with clear states and honest capability reporting.
18. **Archive-format filter** — Add a focused, configurable experience with clear states and honest capability reporting.
19. **Game count by system** — Add a focused, configurable experience with clear states and honest capability reporting.
20. **Library growth timeline** — Add a focused, configurable experience with clear states and honest capability reporting.
21. **Import source labels** — Add a focused, configurable experience with clear states and honest capability reporting.
22. **Manual entry editor** — Add a focused, configurable experience with clear states and honest capability reporting.
23. **Alternate title aliases** — Add a focused, configurable experience with clear states and honest capability reporting.
24. **Preferred title override** — Add a focused, configurable experience with clear states and honest capability reporting.
25. **Custom sort tie-breakers** — Add a focused, configurable experience with clear states and honest capability reporting.
26. **Random game by filter** — Add a focused, configurable experience with clear states and honest capability reporting.
27. **Random game from shelf** — Add a focused, configurable experience with clear states and honest capability reporting.
28. **Exclude recent random picks** — Add a focused, configurable experience with clear states and honest capability reporting.
29. **Pin game to top** — Add a focused, configurable experience with clear states and honest capability reporting.
30. **Pin system to top** — Add a focused, configurable experience with clear states and honest capability reporting.
31. **System shelf grouping** — Add a focused, configurable experience with clear states and honest capability reporting.
32. **Collapse empty systems** — Add a focused, configurable experience with clear states and honest capability reporting.
33. **Hide unsupported systems** — Add a focused, configurable experience with clear states and honest capability reporting.
34. **Show system aliases** — Add a focused, configurable experience with clear states and honest capability reporting.
35. **Per-system card layout** — Add a focused, configurable experience with clear states and honest capability reporting.
36. **Per-system artwork preference** — Add a focused, configurable experience with clear states and honest capability reporting.
37. **Per-system metadata fields** — Add a focused, configurable experience with clear states and honest capability reporting.
38. **Per-game accent override** — Add a focused, configurable experience with clear states and honest capability reporting.
39. **Per-game background override** — Add a focused, configurable experience with clear states and honest capability reporting.
40. **Per-game launch note** — Add a focused, configurable experience with clear states and honest capability reporting.
41. **Per-game favorite reason** — Add a focused, configurable experience with clear states and honest capability reporting.
42. **Personal game status** — Add a focused, configurable experience with clear states and honest capability reporting.
43. **Game relationship links** — Add a focused, configurable experience with clear states and honest capability reporting.
44. **Related games navigation** — Add a focused, configurable experience with clear states and honest capability reporting.
45. **Series chronology view** — Add a focused, configurable experience with clear states and honest capability reporting.
46. **Collection cover composer** — Add a focused, configurable experience with clear states and honest capability reporting.
47. **Collection description editor** — Add a focused, configurable experience with clear states and honest capability reporting.
48. **Game list density rules** — Add a focused, configurable experience with clear states and honest capability reporting.
49. **Library section bookmarks** — Add a focused, configurable experience with clear states and honest capability reporting.
50. **Library view history** — Add a focused, configurable experience with clear states and honest capability reporting.

## Scanning & imports — 50 concepts

51. **Import wizard presets** — Add a focused, configurable experience with clear states and honest capability reporting.
52. **Folder naming guide** — Add a focused, configurable experience with clear states and honest capability reporting.
53. **Scan selected systems** — Add a focused, configurable experience with clear states and honest capability reporting.
54. **Scan selected folders** — Add a focused, configurable experience with clear states and honest capability reporting.
55. **Scan schedule settings** — Add a focused, configurable experience with clear states and honest capability reporting.
56. **Scan-on-storage-connect** — Add a focused, configurable experience with clear states and honest capability reporting.
57. **Scan-on-app-open** — Add a focused, configurable experience with clear states and honest capability reporting.
58. **Scan activity history** — Add a focused, configurable experience with clear states and honest capability reporting.
59. **Scan duration estimate** — Add a focused, configurable experience with clear states and honest capability reporting.
60. **Scan throughput display** — Add a focused, configurable experience with clear states and honest capability reporting.
61. **New-file detection summary** — Add a focused, configurable experience with clear states and honest capability reporting.
62. **Changed-file detection summary** — Add a focused, configurable experience with clear states and honest capability reporting.
63. **Moved-file detection hints** — Add a focused, configurable experience with clear states and honest capability reporting.
64. **Renamed-file detection hints** — Add a focused, configurable experience with clear states and honest capability reporting.
65. **Unmatched-file inbox** — Add a focused, configurable experience with clear states and honest capability reporting.
66. **Manual match queue** — Add a focused, configurable experience with clear states and honest capability reporting.
67. **Batch match approval** — Add a focused, configurable experience with clear states and honest capability reporting.
68. **Batch metadata refresh** — Add a focused, configurable experience with clear states and honest capability reporting.
69. **Batch artwork refresh** — Add a focused, configurable experience with clear states and honest capability reporting.
70. **Ignore-file rules editor** — Add a focused, configurable experience with clear states and honest capability reporting.
71. **File extension rules** — Add a focused, configurable experience with clear states and honest capability reporting.
72. **Per-folder scraper choice** — Add a focused, configurable experience with clear states and honest capability reporting.
73. **Per-system scraper priority** — Add a focused, configurable experience with clear states and honest capability reporting.
74. **Scraper timeout preferences** — Add a focused, configurable experience with clear states and honest capability reporting.
75. **Scraper retry backoff** — Add a focused, configurable experience with clear states and honest capability reporting.
76. **Scraper request budget** — Add a focused, configurable experience with clear states and honest capability reporting.
77. **Scraper connectivity test** — Add a focused, configurable experience with clear states and honest capability reporting.
78. **Scraper credential test** — Add a focused, configurable experience with clear states and honest capability reporting.
79. **Scraper result comparison** — Add a focused, configurable experience with clear states and honest capability reporting.
80. **Metadata conflict resolver** — Add a focused, configurable experience with clear states and honest capability reporting.
81. **Field-by-field metadata picker** — Add a focused, configurable experience with clear states and honest capability reporting.
82. **Artwork candidate comparison** — Add a focused, configurable experience with clear states and honest capability reporting.
83. **Artwork crop preview** — Add a focused, configurable experience with clear states and honest capability reporting.
84. **Aspect-ratio warnings** — Add a focused, configurable experience with clear states and honest capability reporting.
85. **Local artwork import wizard** — Add a focused, configurable experience with clear states and honest capability reporting.
86. **Local metadata sidecars** — Add a focused, configurable experience with clear states and honest capability reporting.
87. **Sidecar validation report** — Add a focused, configurable experience with clear states and honest capability reporting.
88. **Import manifest export** — Add a focused, configurable experience with clear states and honest capability reporting.
89. **Import manifest restore** — Add a focused, configurable experience with clear states and honest capability reporting.
90. **Folder permission audit** — Add a focused, configurable experience with clear states and honest capability reporting.
91. **Permission renewal checklist** — Add a focused, configurable experience with clear states and honest capability reporting.
92. **Removable drive labels** — Add a focused, configurable experience with clear states and honest capability reporting.
93. **Drive remount recovery** — Add a focused, configurable experience with clear states and honest capability reporting.
94. **Scan cancellation confirmation** — Add a focused, configurable experience with clear states and honest capability reporting.
95. **Scan checkpoint viewer** — Add a focused, configurable experience with clear states and honest capability reporting.
96. **Scan error grouping** — Add a focused, configurable experience with clear states and honest capability reporting.
97. **Unsupported archive report** — Add a focused, configurable experience with clear states and honest capability reporting.
98. **Corrupt archive warning** — Add a focused, configurable experience with clear states and honest capability reporting.
99. **Unrecognized system suggestions** — Add a focused, configurable experience with clear states and honest capability reporting.
100. **Import completion recap** — Add a focused, configurable experience with clear states and honest capability reporting.

## Metadata & media — 50 concepts

101. **Metadata field visibility editor** — Add a focused, configurable experience with clear states and honest capability reporting.
102. **Preferred metadata language** — Add a focused, configurable experience with clear states and honest capability reporting.
103. **Original release date display** — Add a focused, configurable experience with clear states and honest capability reporting.
104. **Regional release date display** — Add a focused, configurable experience with clear states and honest capability reporting.
105. **Alternate box-art selector** — Add a focused, configurable experience with clear states and honest capability reporting.
106. **Front-cover crop editor** — Add a focused, configurable experience with clear states and honest capability reporting.
107. **Back-cover art slot** — Add a focused, configurable experience with clear states and honest capability reporting.
108. **Title-screen image slot** — Add a focused, configurable experience with clear states and honest capability reporting.
109. **Logo-only image slot** — Add a focused, configurable experience with clear states and honest capability reporting.
110. **Clear-logo fallback chain** — Add a focused, configurable experience with clear states and honest capability reporting.
111. **Screenshot ordering controls** — Add a focused, configurable experience with clear states and honest capability reporting.
112. **Screenshot favorite marker** — Add a focused, configurable experience with clear states and honest capability reporting.
113. **Video preview mute preference** — Add a focused, configurable experience with clear states and honest capability reporting.
114. **Video quality cap** — Add a focused, configurable experience with clear states and honest capability reporting.
115. **Video playback limit** — Add a focused, configurable experience with clear states and honest capability reporting.
116. **Animated artwork toggle** — Add a focused, configurable experience with clear states and honest capability reporting.
117. **Artwork transition picker** — Add a focused, configurable experience with clear states and honest capability reporting.
118. **Image cache prefetch rules** — Add a focused, configurable experience with clear states and honest capability reporting.
119. **Image cache eviction rules** — Add a focused, configurable experience with clear states and honest capability reporting.
120. **Missing media placeholder designer** — Add a focused, configurable experience with clear states and honest capability reporting.
121. **Media provenance details** — Add a focused, configurable experience with clear states and honest capability reporting.
122. **Metadata edit history** — Add a focused, configurable experience with clear states and honest capability reporting.
123. **Metadata rollback** — Add a focused, configurable experience with clear states and honest capability reporting.
124. **Metadata lock per field** — Add a focused, configurable experience with clear states and honest capability reporting.
125. **Local metadata priority rules** — Add a focused, configurable experience with clear states and honest capability reporting.
126. **Scraper field mapping editor** — Add a focused, configurable experience with clear states and honest capability reporting.
127. **Custom metadata fields** — Add a focused, configurable experience with clear states and honest capability reporting.
128. **Custom metadata templates** — Add a focused, configurable experience with clear states and honest capability reporting.
129. **Game subtitle field** — Add a focused, configurable experience with clear states and honest capability reporting.
130. **Original platform title field** — Add a focused, configurable experience with clear states and honest capability reporting.
131. **Franchise installment number** — Add a focused, configurable experience with clear states and honest capability reporting.
132. **Developer country field** — Add a focused, configurable experience with clear states and honest capability reporting.
133. **Publisher country field** — Add a focused, configurable experience with clear states and honest capability reporting.
134. **Supported player count source** — Add a focused, configurable experience with clear states and honest capability reporting.
135. **Peripheral compatibility notes** — Add a focused, configurable experience with clear states and honest capability reporting.
136. **Manual language tags** — Add a focused, configurable experience with clear states and honest capability reporting.
137. **Manual page bookmarks** — Add a focused, configurable experience with clear states and honest capability reporting.
138. **Manual text search** — Add a focused, configurable experience with clear states and honest capability reporting.
139. **Manual reading progress** — Add a focused, configurable experience with clear states and honest capability reporting.
140. **Screenshot annotation notes** — Add a focused, configurable experience with clear states and honest capability reporting.
141. **Screenshot compare mode** — Add a focused, configurable experience with clear states and honest capability reporting.
142. **Screenshot slideshow order** — Add a focused, configurable experience with clear states and honest capability reporting.
143. **Trailer source label** — Add a focused, configurable experience with clear states and honest capability reporting.
144. **Video resume point** — Add a focused, configurable experience with clear states and honest capability reporting.
145. **Media file integrity check** — Add a focused, configurable experience with clear states and honest capability reporting.
146. **Artwork duplicate detector** — Add a focused, configurable experience with clear states and honest capability reporting.
147. **Artwork filename normalizer** — Add a focused, configurable experience with clear states and honest capability reporting.
148. **Metadata quality explanation** — Add a focused, configurable experience with clear states and honest capability reporting.
149. **Per-game metadata export** — Add a focused, configurable experience with clear states and honest capability reporting.
150. **Metadata sidecar editor** — Add a focused, configurable experience with clear states and honest capability reporting.

## Save data & continuity — 50 concepts

151. **Save folder overview** — Add a focused, configurable experience with clear states and honest capability reporting.
152. **Save file timestamp timeline** — Add a focused, configurable experience with clear states and honest capability reporting.
153. **Save file size history** — Add a focused, configurable experience with clear states and honest capability reporting.
154. **Save slot labels** — Add a focused, configurable experience with clear states and honest capability reporting.
155. **Save slot notes** — Add a focused, configurable experience with clear states and honest capability reporting.
156. **Save-state naming templates** — Add a focused, configurable experience with clear states and honest capability reporting.
157. **Save-state thumbnail browser** — Add a focused, configurable experience with clear states and honest capability reporting.
158. **Save-state metadata viewer** — Add a focused, configurable experience with clear states and honest capability reporting.
159. **Save-state compatibility warning** — Add a focused, configurable experience with clear states and honest capability reporting.
160. **Save-state backup reminder** — Add a focused, configurable experience with clear states and honest capability reporting.
161. **Save backup rotation** — Add a focused, configurable experience with clear states and honest capability reporting.
162. **Save folder mapping validator** — Add a focused, configurable experience with clear states and honest capability reporting.
163. **Save path conflict detector** — Add a focused, configurable experience with clear states and honest capability reporting.
164. **Per-emulator save location guide** — Add a focused, configurable experience with clear states and honest capability reporting.
165. **Save directory permission status** — Add a focused, configurable experience with clear states and honest capability reporting.
166. **Save archive preview** — Add a focused, configurable experience with clear states and honest capability reporting.
167. **Save archive integrity check** — Add a focused, configurable experience with clear states and honest capability reporting.
168. **Save backup encryption option** — Add a focused, configurable experience with clear states and honest capability reporting.
169. **Backup recovery reminder** — Add a focused, configurable experience with clear states and honest capability reporting.
170. **Backup version comparison** — Add a focused, configurable experience with clear states and honest capability reporting.
171. **Backup contents manifest** — Add a focused, configurable experience with clear states and honest capability reporting.
172. **Selective backup restore** — Add a focused, configurable experience with clear states and honest capability reporting.
173. **Restore dry-run preview** — Add a focused, configurable experience with clear states and honest capability reporting.
174. **Restore conflict resolver** — Add a focused, configurable experience with clear states and honest capability reporting.
175. **Restore progress history** — Add a focused, configurable experience with clear states and honest capability reporting.
176. **Save sync conflict inbox** — Add a focused, configurable experience with clear states and honest capability reporting.
177. **Manual sync trigger** — Add a focused, configurable experience with clear states and honest capability reporting.
178. **Sync bandwidth limit** — Add a focused, configurable experience with clear states and honest capability reporting.
179. **Sync Wi-Fi-only preference** — Add a focused, configurable experience with clear states and honest capability reporting.
180. **Sync battery threshold** — Add a focused, configurable experience with clear states and honest capability reporting.
181. **Sync pause/resume controls** — Add a focused, configurable experience with clear states and honest capability reporting.
182. **Sync retry queue** — Add a focused, configurable experience with clear states and honest capability reporting.
183. **Sync provider health panel** — Add a focused, configurable experience with clear states and honest capability reporting.
184. **Sync last-success timestamp** — Add a focused, configurable experience with clear states and honest capability reporting.
185. **Sync quota display** — Add a focused, configurable experience with clear states and honest capability reporting.
186. **Sync excluded-folder rules** — Add a focused, configurable experience with clear states and honest capability reporting.
187. **Sync device pairing labels** — Add a focused, configurable experience with clear states and honest capability reporting.
188. **Sync device revoke control** — Add a focused, configurable experience with clear states and honest capability reporting.
189. **Save transfer audit log** — Add a focused, configurable experience with clear states and honest capability reporting.
190. **Save import compatibility notes** — Add a focused, configurable experience with clear states and honest capability reporting.
191. **Save format association editor** — Add a focused, configurable experience with clear states and honest capability reporting.
192. **Save data orphan finder** — Add a focused, configurable experience with clear states and honest capability reporting.
193. **Save cleanup preview** — Add a focused, configurable experience with clear states and honest capability reporting.
194. **Save backup verification test** — Add a focused, configurable experience with clear states and honest capability reporting.
195. **Save recovery checklist** — Add a focused, configurable experience with clear states and honest capability reporting.
196. **Save migration assistant** — Add a focused, configurable experience with clear states and honest capability reporting.
197. **Save version pinning** — Add a focused, configurable experience with clear states and honest capability reporting.
198. **Save archive export** — Add a focused, configurable experience with clear states and honest capability reporting.
199. **Save archive import** — Add a focused, configurable experience with clear states and honest capability reporting.
200. **Save restore history** — Add a focused, configurable experience with clear states and honest capability reporting.

## Controllers & input — 50 concepts

201. **Controller connection timeline** — Add a focused, configurable experience with clear states and honest capability reporting.
202. **Controller battery status** — Add a focused, configurable experience with clear states and honest capability reporting.
203. **Controller firmware note field** — Add a focused, configurable experience with clear states and honest capability reporting.
204. **Controller device rename** — Add a focused, configurable experience with clear states and honest capability reporting.
205. **Controller order preference** — Add a focused, configurable experience with clear states and honest capability reporting.
206. **Controller player assignment** — Add a focused, configurable experience with clear states and honest capability reporting.
207. **Controller hotplug settings** — Add a focused, configurable experience with clear states and honest capability reporting.
208. **Controller disconnect grace period** — Add a focused, configurable experience with clear states and honest capability reporting.
209. **Controller reconnect vibration toggle** — Add a focused, configurable experience with clear states and honest capability reporting.
210. **Button mapping conflict checker** — Add a focused, configurable experience with clear states and honest capability reporting.
211. **Mapping import preview** — Add a focused, configurable experience with clear states and honest capability reporting.
212. **Mapping export with device notes** — Add a focused, configurable experience with clear states and honest capability reporting.
213. **Mapping version history** — Add a focused, configurable experience with clear states and honest capability reporting.
214. **Mapping rollback** — Add a focused, configurable experience with clear states and honest capability reporting.
215. **Per-system mapping defaults** — Add a focused, configurable experience with clear states and honest capability reporting.
216. **Per-game mapping inheritance** — Add a focused, configurable experience with clear states and honest capability reporting.
217. **Mapping override explanation** — Add a focused, configurable experience with clear states and honest capability reporting.
218. **Analog axis visualizer** — Add a focused, configurable experience with clear states and honest capability reporting.
219. **Trigger range visualizer** — Add a focused, configurable experience with clear states and honest capability reporting.
220. **Stick center calibration record** — Add a focused, configurable experience with clear states and honest capability reporting.
221. **Stick sensitivity curves** — Add a focused, configurable experience with clear states and honest capability reporting.
222. **Radial dead-zone option** — Add a focused, configurable experience with clear states and honest capability reporting.
223. **Axial dead-zone option** — Add a focused, configurable experience with clear states and honest capability reporting.
224. **Invert axis per game** — Add a focused, configurable experience with clear states and honest capability reporting.
225. **Swap stick axes** — Add a focused, configurable experience with clear states and honest capability reporting.
226. **Swap face-button labels** — Add a focused, configurable experience with clear states and honest capability reporting.
227. **Nintendo confirm layout** — Add a focused, configurable experience with clear states and honest capability reporting.
228. **PlayStation confirm layout** — Add a focused, configurable experience with clear states and honest capability reporting.
229. **Xbox confirm layout** — Add a focused, configurable experience with clear states and honest capability reporting.
230. **Custom button glyph pack** — Add a focused, configurable experience with clear states and honest capability reporting.
231. **Glyph pack preview** — Add a focused, configurable experience with clear states and honest capability reporting.
232. **Controller navigation sound toggle** — Add a focused, configurable experience with clear states and honest capability reporting.
233. **Controller focus animation setting** — Add a focused, configurable experience with clear states and honest capability reporting.
234. **Shortcut conflict viewer** — Add a focused, configurable experience with clear states and honest capability reporting.
235. **Shortcut profile presets** — Add a focused, configurable experience with clear states and honest capability reporting.
236. **Keyboard navigation profile** — Add a focused, configurable experience with clear states and honest capability reporting.
237. **Mouse navigation profile** — Add a focused, configurable experience with clear states and honest capability reporting.
238. **Touch gesture configuration** — Add a focused, configurable experience with clear states and honest capability reporting.
239. **Swipe shelf navigation** — Add a focused, configurable experience with clear states and honest capability reporting.
240. **Long-press action editor** — Add a focused, configurable experience with clear states and honest capability reporting.
241. **Controller wake behavior** — Add a focused, configurable experience with clear states and honest capability reporting.
242. **Controller sleep behavior** — Add a focused, configurable experience with clear states and honest capability reporting.
243. **Virtual cursor toggle** — Add a focused, configurable experience with clear states and honest capability reporting.
244. **Pointer speed setting** — Add a focused, configurable experience with clear states and honest capability reporting.
245. **Wii pointer calibration notes** — Add a focused, configurable experience with clear states and honest capability reporting.
246. **Touch-to-controller mapping** — Add a focused, configurable experience with clear states and honest capability reporting.
247. **Accessibility switch input mapping** — Add a focused, configurable experience with clear states and honest capability reporting.
248. **Input diagnostic export** — Add a focused, configurable experience with clear states and honest capability reporting.
249. **Controller test recording** — Add a focused, configurable experience with clear states and honest capability reporting.
250. **Controller profile compatibility tags** — Add a focused, configurable experience with clear states and honest capability reporting.

## Console immersion — 50 concepts

251. **Per-system boot skip memory** — Add a focused, configurable experience with clear states and honest capability reporting.
252. **Boot sequence duration slider** — Add a focused, configurable experience with clear states and honest capability reporting.
253. **Boot sequence preview gallery** — Add a focused, configurable experience with clear states and honest capability reporting.
254. **System home background playlist** — Add a focused, configurable experience with clear states and honest capability reporting.
255. **System home soundtrack playlist** — Add a focused, configurable experience with clear states and honest capability reporting.
256. **System home widget slots** — Add a focused, configurable experience with clear states and honest capability reporting.
257. **System home clock style** — Add a focused, configurable experience with clear states and honest capability reporting.
258. **System home date format** — Add a focused, configurable experience with clear states and honest capability reporting.
259. **System home status strip** — Add a focused, configurable experience with clear states and honest capability reporting.
260. **Console home page indicators** — Add a focused, configurable experience with clear states and honest capability reporting.
261. **Console home category editor** — Add a focused, configurable experience with clear states and honest capability reporting.
262. **Console home quick links** — Add a focused, configurable experience with clear states and honest capability reporting.
263. **Console home recent row** — Add a focused, configurable experience with clear states and honest capability reporting.
264. **Console home favorites row** — Add a focused, configurable experience with clear states and honest capability reporting.
265. **Console home hidden channels** — Add a focused, configurable experience with clear states and honest capability reporting.
266. **Console home channel ordering** — Add a focused, configurable experience with clear states and honest capability reporting.
267. **Console home tile size** — Add a focused, configurable experience with clear states and honest capability reporting.
268. **Console home tile shape** — Add a focused, configurable experience with clear states and honest capability reporting.
269. **Console home focus depth** — Add a focused, configurable experience with clear states and honest capability reporting.
270. **Console home parallax strength** — Add a focused, configurable experience with clear states and honest capability reporting.
271. **Console home transition direction** — Add a focused, configurable experience with clear states and honest capability reporting.
272. **Console home idle timeout** — Add a focused, configurable experience with clear states and honest capability reporting.
273. **System logo motion preset** — Add a focused, configurable experience with clear states and honest capability reporting.
274. **System identity color extraction** — Add a focused, configurable experience with clear states and honest capability reporting.
275. **System UI sound volume** — Add a focused, configurable experience with clear states and honest capability reporting.
276. **System UI sound mute** — Add a focused, configurable experience with clear states and honest capability reporting.
277. **System reduced motion** — Add a focused, configurable experience with clear states and honest capability reporting.
278. **System contrast preset** — Add a focused, configurable experience with clear states and honest capability reporting.
279. **Game launch curtain style** — Add a focused, configurable experience with clear states and honest capability reporting.
280. **Game launch title card** — Add a focused, configurable experience with clear states and honest capability reporting.
281. **Game return transition** — Add a focused, configurable experience with clear states and honest capability reporting.
282. **Game exit confirmation style** — Add a focused, configurable experience with clear states and honest capability reporting.
283. **Game session end card** — Add a focused, configurable experience with clear states and honest capability reporting.
284. **Console ambient clock** — Add a focused, configurable experience with clear states and honest capability reporting.
285. **Console screensaver** — Add a focused, configurable experience with clear states and honest capability reporting.
286. **Console wallpaper schedule** — Add a focused, configurable experience with clear states and honest capability reporting.
287. **Seasonal accent toggle** — Add a focused, configurable experience with clear states and honest capability reporting.
288. **Console local media panel** — Add a focused, configurable experience with clear states and honest capability reporting.
289. **Console manual shortcut** — Add a focused, configurable experience with clear states and honest capability reporting.
290. **System facts panel** — Add a focused, configurable experience with clear states and honest capability reporting.
291. **Controller guide overlay** — Add a focused, configurable experience with clear states and honest capability reporting.
292. **Console navigation map** — Add a focused, configurable experience with clear states and honest capability reporting.
293. **Console layout export** — Add a focused, configurable experience with clear states and honest capability reporting.
294. **Console layout import** — Add a focused, configurable experience with clear states and honest capability reporting.
295. **Console reset preview** — Add a focused, configurable experience with clear states and honest capability reporting.
296. **Console greeting preference** — Add a focused, configurable experience with clear states and honest capability reporting.
297. **Console accessibility layout** — Add a focused, configurable experience with clear states and honest capability reporting.
298. **Boot sound preview** — Add a focused, configurable experience with clear states and honest capability reporting.
299. **System-specific loading tips** — Add a focused, configurable experience with clear states and honest capability reporting.
300. **Console home search shortcut** — Add a focused, configurable experience with clear states and honest capability reporting.

## Devices & displays — 50 concepts

301. **Device nickname editor** — Add a focused, configurable experience with clear states and honest capability reporting.
302. **Device capability summary** — Add a focused, configurable experience with clear states and honest capability reporting.
303. **Display resolution readout** — Add a focused, configurable experience with clear states and honest capability reporting.
304. **Display density readout** — Add a focused, configurable experience with clear states and honest capability reporting.
305. **Screen refresh readout** — Add a focused, configurable experience with clear states and honest capability reporting.
306. **Display orientation preference** — Add a focused, configurable experience with clear states and honest capability reporting.
307. **Safe-area preview** — Add a focused, configurable experience with clear states and honest capability reporting.
308. **Overscan adjustment grid** — Add a focused, configurable experience with clear states and honest capability reporting.
309. **UI scaling per display** — Add a focused, configurable experience with clear states and honest capability reporting.
310. **Text scaling per display** — Add a focused, configurable experience with clear states and honest capability reporting.
311. **Secondary display layout preview** — Add a focused, configurable experience with clear states and honest capability reporting.
312. **Secondary display connection warning** — Add a focused, configurable experience with clear states and honest capability reporting.
313. **Secondary display sleep preference** — Add a focused, configurable experience with clear states and honest capability reporting.
314. **Secondary display touch mapping** — Add a focused, configurable experience with clear states and honest capability reporting.
315. **External monitor layout preset** — Add a focused, configurable experience with clear states and honest capability reporting.
316. **TV readability preview** — Add a focused, configurable experience with clear states and honest capability reporting.
317. **Handheld reach zones** — Add a focused, configurable experience with clear states and honest capability reporting.
318. **Landscape control reach map** — Add a focused, configurable experience with clear states and honest capability reporting.
319. **Gesture conflict check** — Add a focused, configurable experience with clear states and honest capability reporting.
320. **Status bar preference** — Add a focused, configurable experience with clear states and honest capability reporting.
321. **Navigation bar preference** — Add a focused, configurable experience with clear states and honest capability reporting.
322. **Immersive mode guide** — Add a focused, configurable experience with clear states and honest capability reporting.
323. **External keyboard detection** — Add a focused, configurable experience with clear states and honest capability reporting.
324. **USB storage connection notice** — Add a focused, configurable experience with clear states and honest capability reporting.
325. **Bluetooth device status** — Add a focused, configurable experience with clear states and honest capability reporting.
326. **Audio output device label** — Add a focused, configurable experience with clear states and honest capability reporting.
327. **Audio route change notice** — Add a focused, configurable experience with clear states and honest capability reporting.
328. **Headphone connect behavior** — Add a focused, configurable experience with clear states and honest capability reporting.
329. **Docked-mode layout preset** — Add a focused, configurable experience with clear states and honest capability reporting.
330. **Undocked-mode layout preset** — Add a focused, configurable experience with clear states and honest capability reporting.
331. **Charging-state visual theme** — Add a focused, configurable experience with clear states and honest capability reporting.
332. **Low-power UI simplification** — Add a focused, configurable experience with clear states and honest capability reporting.
333. **Battery animation reduction** — Add a focused, configurable experience with clear states and honest capability reporting.
334. **Background refresh preference** — Add a focused, configurable experience with clear states and honest capability reporting.
335. **Startup performance trace** — Add a focused, configurable experience with clear states and honest capability reporting.
336. **Frame pacing diagnostics** — Add a focused, configurable experience with clear states and honest capability reporting.
337. **Memory pressure notice** — Add a focused, configurable experience with clear states and honest capability reporting.
338. **Crash recovery summary** — Add a focused, configurable experience with clear states and honest capability reporting.
339. **Device capability change log** — Add a focused, configurable experience with clear states and honest capability reporting.
340. **OS compatibility notes** — Add a focused, configurable experience with clear states and honest capability reporting.
341. **App permission dashboard** — Add a focused, configurable experience with clear states and honest capability reporting.
342. **Permission change history** — Add a focused, configurable experience with clear states and honest capability reporting.
343. **System API availability matrix** — Add a focused, configurable experience with clear states and honest capability reporting.
344. **Feature availability explanations** — Add a focused, configurable experience with clear states and honest capability reporting.
345. **Unsupported feature guide** — Add a focused, configurable experience with clear states and honest capability reporting.
346. **Device profile export** — Add a focused, configurable experience with clear states and honest capability reporting.
347. **Device profile import** — Add a focused, configurable experience with clear states and honest capability reporting.
348. **Device migration checklist** — Add a focused, configurable experience with clear states and honest capability reporting.
349. **Device reset preparation** — Add a focused, configurable experience with clear states and honest capability reporting.
350. **Display color calibration notes** — Add a focused, configurable experience with clear states and honest capability reporting.

## Local multiplayer — 50 concepts

351. **External display hotplug flow** — Add a focused, configurable experience with clear states and honest capability reporting.
352. **Player seat assignment editor** — Add a focused, configurable experience with clear states and honest capability reporting.
353. **Player color labels** — Add a focused, configurable experience with clear states and honest capability reporting.
354. **Local player name labels** — Add a focused, configurable experience with clear states and honest capability reporting.
355. **Local match setup checklist** — Add a focused, configurable experience with clear states and honest capability reporting.
356. **Local match rules notes** — Add a focused, configurable experience with clear states and honest capability reporting.
357. **Game rotation planner** — Add a focused, configurable experience with clear states and honest capability reporting.
358. **Match result entry** — Add a focused, configurable experience with clear states and honest capability reporting.
359. **Match history browser** — Add a focused, configurable experience with clear states and honest capability reporting.
360. **Local league standings** — Add a focused, configurable experience with clear states and honest capability reporting.
361. **Round-robin schedule** — Add a focused, configurable experience with clear states and honest capability reporting.
362. **Single-elimination bracket** — Add a focused, configurable experience with clear states and honest capability reporting.
363. **Double-elimination bracket** — Add a focused, configurable experience with clear states and honest capability reporting.
364. **Random team splitter** — Add a focused, configurable experience with clear states and honest capability reporting.
365. **Manual-rating team balancer** — Add a focused, configurable experience with clear states and honest capability reporting.
366. **Player availability planner** — Add a focused, configurable experience with clear states and honest capability reporting.
367. **Controller seat test** — Add a focused, configurable experience with clear states and honest capability reporting.
368. **Controller handoff prompt** — Add a focused, configurable experience with clear states and honest capability reporting.
369. **Player order presets** — Add a focused, configurable experience with clear states and honest capability reporting.
370. **Tournament rules templates** — Add a focused, configurable experience with clear states and honest capability reporting.
371. **Tournament rules editor** — Add a focused, configurable experience with clear states and honest capability reporting.
372. **Match timer overlay** — Add a focused, configurable experience with clear states and honest capability reporting.
373. **Between-round break timer** — Add a focused, configurable experience with clear states and honest capability reporting.
374. **Scoreboard overlay** — Add a focused, configurable experience with clear states and honest capability reporting.
375. **Scoreboard theme editor** — Add a focused, configurable experience with clear states and honest capability reporting.
376. **Local spectator display** — Add a focused, configurable experience with clear states and honest capability reporting.
377. **Second-screen scoreboard** — Add a focused, configurable experience with clear states and honest capability reporting.
378. **Event announcement card** — Add a focused, configurable experience with clear states and honest capability reporting.
379. **Match recap card** — Add a focused, configurable experience with clear states and honest capability reporting.
380. **Match screenshot attachment** — Add a focused, configurable experience with clear states and honest capability reporting.
381. **Manually entered player stats** — Add a focused, configurable experience with clear states and honest capability reporting.
382. **Head-to-head history** — Add a focused, configurable experience with clear states and honest capability reporting.
383. **Rivalry notes** — Add a focused, configurable experience with clear states and honest capability reporting.
384. **Friendly challenge cards** — Add a focused, configurable experience with clear states and honest capability reporting.
385. **Practice drill checklist** — Add a focused, configurable experience with clear states and honest capability reporting.
386. **Practice drill library** — Add a focused, configurable experience with clear states and honest capability reporting.
387. **Local co-op finder** — Add a focused, configurable experience with clear states and honest capability reporting.
388. **Local versus finder** — Add a focused, configurable experience with clear states and honest capability reporting.
389. **Player-count confidence label** — Add a focused, configurable experience with clear states and honest capability reporting.
390. **Shared session QR pairing** — Add a focused, configurable experience with clear states and honest capability reporting.
391. **Nearby-device pairing approval** — Add a focused, configurable experience with clear states and honest capability reporting.
392. **Session invitation code** — Add a focused, configurable experience with clear states and honest capability reporting.
393. **Session host handoff** — Add a focused, configurable experience with clear states and honest capability reporting.
394. **Session join confirmation** — Add a focused, configurable experience with clear states and honest capability reporting.
395. **Guest controller setup** — Add a focused, configurable experience with clear states and honest capability reporting.
396. **Temporary guest profile** — Add a focused, configurable experience with clear states and honest capability reporting.
397. **Local party privacy mode** — Add a focused, configurable experience with clear states and honest capability reporting.
398. **Party session archive** — Add a focused, configurable experience with clear states and honest capability reporting.
399. **Party setup export** — Add a focused, configurable experience with clear states and honest capability reporting.
400. **Local event calendar** — Add a focused, configurable experience with clear states and honest capability reporting.

## Accessibility — 50 concepts

401. **Team color presets** — Add a focused, configurable experience with clear states and honest capability reporting.
402. **High-visibility focus mode** — Add a focused, configurable experience with clear states and honest capability reporting.
403. **Extra-large focus outline** — Add a focused, configurable experience with clear states and honest capability reporting.
404. **Focus animation disable** — Add a focused, configurable experience with clear states and honest capability reporting.
405. **Text-to-speech navigation labels** — Add a focused, configurable experience with clear states and honest capability reporting.
406. **Screen reader route descriptions** — Add a focused, configurable experience with clear states and honest capability reporting.
407. **Spoken game metadata summary** — Add a focused, configurable experience with clear states and honest capability reporting.
408. **Speech rate preference** — Add a focused, configurable experience with clear states and honest capability reporting.
409. **UI sound captions** — Add a focused, configurable experience with clear states and honest capability reporting.
410. **Sound effect volume mixer** — Add a focused, configurable experience with clear states and honest capability reporting.
411. **Mono audio guide** — Add a focused, configurable experience with clear states and honest capability reporting.
412. **Color filter note** — Add a focused, configurable experience with clear states and honest capability reporting.
413. **Color-independent status icons** — Add a focused, configurable experience with clear states and honest capability reporting.
414. **High contrast card mode** — Add a focused, configurable experience with clear states and honest capability reporting.
415. **Low contrast reduction** — Add a focused, configurable experience with clear states and honest capability reporting.
416. **Dyslexia-friendly font option** — Add a focused, configurable experience with clear states and honest capability reporting.
417. **Font preview page** — Add a focused, configurable experience with clear states and honest capability reporting.
418. **Adjustable line spacing** — Add a focused, configurable experience with clear states and honest capability reporting.
419. **Simplified settings mode** — Add a focused, configurable experience with clear states and honest capability reporting.
420. **Beginner navigation hints** — Add a focused, configurable experience with clear states and honest capability reporting.
421. **Controller-only onboarding** — Add a focused, configurable experience with clear states and honest capability reporting.
422. **Touch-only onboarding** — Add a focused, configurable experience with clear states and honest capability reporting.
423. **One-action-at-a-time mode** — Add a focused, configurable experience with clear states and honest capability reporting.
424. **Confirm focus before launch** — Add a focused, configurable experience with clear states and honest capability reporting.
425. **Accidental launch guard** — Add a focused, configurable experience with clear states and honest capability reporting.
426. **Long-press accessibility alternative** — Add a focused, configurable experience with clear states and honest capability reporting.
427. **Remappable back action** — Add a focused, configurable experience with clear states and honest capability reporting.
428. **Remappable confirm action** — Add a focused, configurable experience with clear states and honest capability reporting.
429. **Sticky navigation preference** — Add a focused, configurable experience with clear states and honest capability reporting.
430. **Reduced animation loading** — Add a focused, configurable experience with clear states and honest capability reporting.
431. **No autoplay media preference** — Add a focused, configurable experience with clear states and honest capability reporting.
432. **No background video preference** — Add a focused, configurable experience with clear states and honest capability reporting.
433. **Quiet hours for UI sounds** — Add a focused, configurable experience with clear states and honest capability reporting.
434. **Night brightness preset** — Add a focused, configurable experience with clear states and honest capability reporting.
435. **Manual reading mode** — Add a focused, configurable experience with clear states and honest capability reporting.
436. **Local video caption support** — Add a focused, configurable experience with clear states and honest capability reporting.
437. **Subtitle size preference** — Add a focused, configurable experience with clear states and honest capability reporting.
438. **Subtitle background preference** — Add a focused, configurable experience with clear states and honest capability reporting.
439. **Audio description metadata note** — Add a focused, configurable experience with clear states and honest capability reporting.
440. **Motion sensitivity preset** — Add a focused, configurable experience with clear states and honest capability reporting.
441. **Flashing content warning** — Add a focused, configurable experience with clear states and honest capability reporting.
442. **Pause animation when unfocused** — Add a focused, configurable experience with clear states and honest capability reporting.
443. **Idle timeout setting** — Add a focused, configurable experience with clear states and honest capability reporting.
444. **Break reminder opt-in** — Add a focused, configurable experience with clear states and honest capability reporting.
445. **Session length reminder** — Add a focused, configurable experience with clear states and honest capability reporting.
446. **Reminder quiet mode** — Add a focused, configurable experience with clear states and honest capability reporting.
447. **Privacy-first guest mode** — Add a focused, configurable experience with clear states and honest capability reporting.
448. **Clear recent activity action** — Add a focused, configurable experience with clear states and honest capability reporting.
449. **Activity retention period** — Add a focused, configurable experience with clear states and honest capability reporting.
450. **Accessibility settings export** — Add a focused, configurable experience with clear states and honest capability reporting.

## Privacy, automation & creators — 50 concepts

451. **Controller focus narration** — Add a focused, configurable experience with clear states and honest capability reporting.
452. **Local data inventory screen** — Add a focused, configurable experience with clear states and honest capability reporting.
453. **Cloud data inventory screen** — Add a focused, configurable experience with clear states and honest capability reporting.
454. **Provider connection inventory** — Add a focused, configurable experience with clear states and honest capability reporting.
455. **Provider permission summary** — Add a focused, configurable experience with clear states and honest capability reporting.
456. **AI data handling explainer** — Add a focused, configurable experience with clear states and honest capability reporting.
457. **AI local-only shortcut** — Add a focused, configurable experience with clear states and honest capability reporting.
458. **AI conversation retention setting** — Add a focused, configurable experience with clear states and honest capability reporting.
459. **AI action approval history** — Add a focused, configurable experience with clear states and honest capability reporting.
460. **AI provider connection test** — Add a focused, configurable experience with clear states and honest capability reporting.
461. **AI provider disconnect** — Add a focused, configurable experience with clear states and honest capability reporting.
462. **AI usage budget indicator** — Add a focused, configurable experience with clear states and honest capability reporting.
463. **AI prompt privacy warning** — Add a focused, configurable experience with clear states and honest capability reporting.
464. **Secret detection in diagnostics** — Add a focused, configurable experience with clear states and honest capability reporting.
465. **Diagnostic redaction preview** — Add a focused, configurable experience with clear states and honest capability reporting.
466. **Diagnostic sharing consent** — Add a focused, configurable experience with clear states and honest capability reporting.
467. **Crash report sharing consent** — Add a focused, configurable experience with clear states and honest capability reporting.
468. **Telemetry opt-in status** — Add a focused, configurable experience with clear states and honest capability reporting.
469. **Telemetry pause control** — Add a focused, configurable experience with clear states and honest capability reporting.
470. **Network transfer audit** — Add a focused, configurable experience with clear states and honest capability reporting.
471. **Paired device trust list** — Add a focused, configurable experience with clear states and honest capability reporting.
472. **Paired device expiry setting** — Add a focused, configurable experience with clear states and honest capability reporting.
473. **Revoke device pairings** — Add a focused, configurable experience with clear states and honest capability reporting.
474. **Theme package signature check** — Add a focused, configurable experience with clear states and honest capability reporting.
475. **Theme permission summary** — Add a focused, configurable experience with clear states and honest capability reporting.
476. **Plugin permission manifest viewer** — Add a focused, configurable experience with clear states and honest capability reporting.
477. **Plugin capability approval** — Add a focused, configurable experience with clear states and honest capability reporting.
478. **Plugin disable switch** — Add a focused, configurable experience with clear states and honest capability reporting.
479. **Plugin uninstall data preview** — Add a focused, configurable experience with clear states and honest capability reporting.
480. **Plugin update review** — Add a focused, configurable experience with clear states and honest capability reporting.
481. **Plugin error isolation report** — Add a focused, configurable experience with clear states and honest capability reporting.
482. **Configuration checksum verifier** — Add a focused, configurable experience with clear states and honest capability reporting.
483. **Configuration recovery point** — Add a focused, configurable experience with clear states and honest capability reporting.
484. **Settings change audit log** — Add a focused, configurable experience with clear states and honest capability reporting.
485. **Sensitive setting re-auth prompt** — Add a focused, configurable experience with clear states and honest capability reporting.
486. **App lock integration guide** — Add a focused, configurable experience with clear states and honest capability reporting.
487. **Guest mode data isolation** — Add a focused, configurable experience with clear states and honest capability reporting.
488. **Guest session cleanup preview** — Add a focused, configurable experience with clear states and honest capability reporting.
489. **Private shelf visibility** — Add a focused, configurable experience with clear states and honest capability reporting.
490. **Hide recent activity toggle** — Add a focused, configurable experience with clear states and honest capability reporting.
491. **Clear search history** — Add a focused, configurable experience with clear states and honest capability reporting.
492. **Search history retention** — Add a focused, configurable experience with clear states and honest capability reporting.
493. **Local database integrity check** — Add a focused, configurable experience with clear states and honest capability reporting.
494. **Database backup verification** — Add a focused, configurable experience with clear states and honest capability reporting.
495. **Database restore compatibility** — Add a focused, configurable experience with clear states and honest capability reporting.
496. **Safe mode startup option** — Add a focused, configurable experience with clear states and honest capability reporting.
497. **Startup troubleshooting log** — Add a focused, configurable experience with clear states and honest capability reporting.
498. **Permission revocation recovery** — Add a focused, configurable experience with clear states and honest capability reporting.
499. **Security update notice center** — Add a focused, configurable experience with clear states and honest capability reporting.
500. **Provider outage status** — Add a focused, configurable experience with clear states and honest capability reporting.

## Implementation guidance

1. Audit every concept against existing code and the previous 100-feature backlog.
2. Mark existing capabilities as reuse rather than new work.
3. Rank the remaining concepts by user impact, feasibility, and regression risk.
4. Build foundations before dependent features: data models, permissions, settings, localization, and tests.
5. Verify Android handheld behavior, including single-screen and dual-screen layouts, before marking hardware-dependent features complete.

**Count: 500 additional concepts across 10 categories.**