# Enums
### element <sub>\<int></sub>
###### The ID of each forum element.
| Index | Value |
| :-: | :-: |
| topic | 03 |
| message | 04 |
| tribe | 09 |
| profile | 10 |
| private_message | 12 |
| poll | 34 |
| image | 45 |

---
### community <sub>\<int></sub>
###### The ID of each forum community.
| Index | Value |
| :-: | :-: |
| atelier801 | 000005 |
| transformice | 000006 |
| bouboum | 000007 |
| fortoresse | 000008 |
| nekodancer | 508574 |

---
### section <sub>\<string></sub>
###### The names of the official sections.
| Index |
| :-: |
| announcements | 
| discussions | 
| off_topic | 
| forum_games | 
| tribes | 
| map_submissions | 
| map_editor | 
| modules | 
| fanart | 
| suggestions | 
| bugs | 
| archives | 

---
### location <sub>\<table></sub>
###### The path location of the official sections on forums.
**Structure**:
```
[enums.community]
	└ [enums.forum]
		└ [enums.section]
```
---
### displayState <sub>\<int></sub>
###### The IDs of the available display states of an element. (Topic, Section, ...)
| Index | Value |
| :-: | :-: |
| active | 0 |
| locked | 1 |
| deleted | 2 |

---
### inboxLocale <sub>\<int></sub>
###### The IDs of the available locales on the mail box.
| Index | Value |
| :-: | :-: |
| inbox | 0 |
| archives | 1 |
| bin | 2 |

---
### messageState <sub>\<int></sub>
###### The IDs of the available display states of a message.
| Index | Value |
| :-: | :-: |
| active | 0 |
| moderated | 1 |

---
### contentState <sub>\<string></sub>
###### The content state for image (un)restrictions.
| Index | Value |
| :-: | :-: |
| restricted | true |
| unrestricted | false |

---
### role <sub>\<int></sub>
###### The IDs of the roles of each staff discriminator.
| Index | Value |
| :-: | :-: |
| administrator | 01 |
| moderator | 10 |
| sentinel | 15 |
| mapcrew | 20 |

---
### searchType <sub>\<int></sub>
###### The IDs of the search types.
| Index | Value |
| :-: | :-: |
| message_topic | 04 |
| tribe | 09 |
| player | 10 |

---
### searchLocation <sub>\<int></sub>
###### The search locales for the specific `SearchType.message_topic` enumeration.
| Index | Value |
| :-: | :-: |
| posts | 1 |
| titles | 2 |
| both | 3 |

---
### sectionIcon <sub>\<string></sub>
###### The available icons for sections.
| Index | Value |
| :-: | :-: |
| nekodancer | nekodancer.png |
| fortoresse | fortoresse.png |
| balloon_cheese | bulle-fromage.png |
| transformice | transformice.png |
| balloon_dots | bulle-pointillets.png |
| wip | wip.png |
| megaphone | megaphone.png |
| skull | crane.png |
| atelier801 | atelier801.png |
| brush | pinceau.png |
| grass | picto.png |
| bouboum | bouboum.png |
| hole | trou-souris.png |
| deadmaze | deadmaze.png |
| cogwheel | roue-dentee.png |
| dice | de.png |
| flag | drapeau.png |
| runforcheese | runforcheese.png |

---
### listRole <sub>\<int></sub>
###### The available roles for the staff list.
| Index | Value |
| :-: | :-: |
| moderator | 0001 |
| sentinel | 0004 |
| arbitre | 0008 |
| mapcrew | 0016 |
| module_team | 0032 |
| anti_hack_brigade | 0064 |
| administrator | 0128 |
| votecrew | 0512 |
| translator | 1024 |
| funcorp | 2048 |

---
### forumTitle <sub>\<string></sub>
###### The available forum titles.
| Index | Value |
| :-: | :-: |
| 1 | Citizen |
| 2 | Censor |
| 3 | Consul |
| 4 | Senator |
| 5 | Archon |
| 6 | Heliast |

---
### topicIcon <sub>\<string></sub>
###### The available icons for a topic.
| Index | Value |
| :-: | :-: |
| poll | sondage%.png |
| private_discussion | bulle%-pointillets%.png |
| private_message | enveloppe%.png |
| postit | postit%.png |
| locked | cadenas%.png |
| deleted | /no%.png |

---
### gender <sub>\<int></sub>
###### The available genders on profile.
| Index | Value |
| :-: | :-: |
| none | 0 |
| female | 1 |
| male | 2 |

---
### recruitmentState <sub>\<int></sub>
###### The recruitment state for tribes.
| Index | Value |
| :-: | :-: |
| closed | 0 |
| open | 1 |

---
### misc <sub>\<int></sub>
###### Miscellaneous values for various purposes.<br>`non_member` -> Tribe section permission to allow non members to have access to something.
| Index | Value |
| :-: | :-: |
| non_member | -2 |
