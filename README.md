# YTAlertView
A custom AlertView, support appearance ui and custom view, replacing target with block processing.

Appearance UI
----
```
[[YTAlertView appearance] setTitleAttributeDictionary:@{NSFontAttributeName:[UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor redColor]}];
[[YTAlertView appearance] setMessageAttributeDictionary:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSForegroundColorAttributeName:[UIColor grayColor]}];
[[YTAlertView appearance] setButtonTitleAttributeDictionary:@{NSFontAttributeName:[UIFont italicSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor greenColor]}];
```

Examples:
----
1
---
```
[YTAlertView showAlertWithTitle:@"title" message:@"message" cancelTitle:@"cancel" otherTitle:@"ok" completion:nil];
```
2
---
```
YTAlertView *alertView = [[YTAlertView alloc] initWithTitle:@"title" message:@"参考消息网7月3日报道，日媒称，7月1日，中日印和东盟（ASEAN）等16国在东京都举行了《区域全面经济伙伴关系协定》（RCEP）部长级会议。会议发表的《联合新闻声明》表示，“努力在年底前形成一揽子成果”，针对为年内达成妥协而加快谈判的方针达成一致。日本经济产业相世耕弘成也在会议后的新闻发布会上表示，“力争年底达成基本协议”。据《日本经济新闻》网站7月2日报道，《联合新闻声明》表示“在当前全球贸易面临单边主义挑战的背景下，尽快结束RCEP谈判至关重要”，与日本一起担任联合主席的新加坡的贸工部长陈振声表示，“力争年内达成实质性协议”。报道指出，如果RCEP达成协议，将诞生覆盖世界人口约一半、国内生产总值（GDP）和贸易额约3成的自由贸易区。规模超过11国参加的《跨太平洋伙伴关系协定》（TPP），在企业进军海外等方面，将给日本带来巨大利益。日本首相安倍晋三也呼吁称“将打造自由而遵守规则的公平市场”。RCEP如果达成协议，还将对加强保护主义的美国形成牵制。报道注意到，在美国退出TPP之后，日本一直在推动TPP11走向生效。如果通过TPP实现较高水平的自由化，并与新兴市场国家保持一致步调，在推动RCEP时，也容易向中国和印度等提出高水平的自由化框架。" cancelButtonTitle:nil otherButtonTitles:@"取消", nil];
    [alertView show:^(BOOL cancel, NSInteger buttonIndex, YTAlertView *alert) {

    }];
```
3
---
```
YTAlertView *alertView = [[YTAlertView alloc] initWithTitle:@"title" message:@"message" cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [YTAlertView alertViewWidth]-16, 400)];
    label.numberOfLines = 0;
    label.text = @"参考消息网7月3日报道，日媒称，7月1日，中日印和东盟（ASEAN）等16国在东京都举行了《区域全面经济伙伴关系协定》（RCEP）部长级会议。会议发表的《联合新闻声明》表示，“努力在年底前形成一揽子成果”，针对为年内达成妥协而加快谈判的方针达成一致。日本经济产业相世耕弘成也在会议后的新闻发布会上表示，“力争年底达成基本协议”。据《日本经济新闻》网站7月2日报道，《联合新闻声明》表示“在当前全球贸易面临单边主义挑战的背景下，尽快结束RCEP谈判至关重要”，与日本一起担任联合主席的新加坡的贸工部长陈振声表示，“力争年内达成实质性协议”。报道指出，如果RCEP达成协议，将诞生覆盖世界人口约一半、国内生产总值（GDP）和贸易额约3成的自由贸易区。规模超过11国参加的《跨太平洋伙伴关系协定》（TPP），在企业进军海外等方面，将给日本带来巨大利益。日本首相安倍晋三也呼吁称“将打造自由而遵守规则的公平市场”。RCEP如果达成协议，还将对加强保护主义的美国形成牵制。报道注意到，在美国退出TPP之后，日本一直在推动TPP11走向生效。如果通过TPP实现较高水平的自由化，并与新兴市场国家保持一致步调，在推动RCEP时，也容易向中国和印度等提出高水平的自由化框架。";
    label.font = [UIFont systemFontOfSize:14];
    
    [alertView setCustomView:label];
    [alertView show:^(BOOL cancel, NSInteger buttonIndex, YTAlertView *alert) {
        
    }];
```

Demo:
----
![YTAlertView](https://github.com/songyutao/YTAlertView/blob/master/YTAlertView/TestYTAlertView/alertview.gif)



