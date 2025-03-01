import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import 'markdown_tags.dart';
import '../config/html_support.dart';
import '../config/style_config.dart';

///Tag:  p
///the paragraph widget
class PWidget extends StatelessWidget {
  final List<m.Node>? children;
  final m.Node parentNode;
  final TextStyle? textStyle;
  final bool? selectable;
  final TextConfig? textConfig;
  final WrapCrossAlignment crossAxisAlignment;

  const PWidget({
    Key? key,
    this.children,
    required this.parentNode,
    this.textStyle,
    this.selectable,
    this.textConfig,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final configSelectable =
        selectable ?? StyleConfig().pConfig?.selectable ?? true;
    return buildRichText(
        children, parentNode, textStyle, configSelectable, textConfig);
  }

  Widget buildRichText(List<m.Node>? children, m.Node parentNode,
      TextStyle? textStyle, bool selectable, TextConfig? textConfig) {
    final config = StyleConfig().pConfig;

    if (selectable) {
      return SelectableText.rich(
        getBlockSpan(
          children,
          parentNode,
          textStyle ?? config?.textStyle ?? defaultPStyle,
        ),
        textAlign: textConfig?.textAlign ??
            config?.textConfig?.textAlign ??
            TextAlign.start,
        textDirection:
            textConfig?.textDirection ?? config?.textConfig?.textDirection,
      );
    }

    return Text.rich(
      getBlockSpan(
        children,
        parentNode,
        textStyle ?? config?.textStyle ?? defaultPStyle,
      ),
      softWrap: true,
      textAlign: textConfig?.textAlign ??
          config?.textConfig?.textAlign ??
          TextAlign.start,
      textDirection:
          textConfig?.textDirection ?? config?.textConfig?.textDirection,
    );
  }

  TextSpan getBlockSpan(
      List<m.Node>? nodes, m.Node parentNode, TextStyle? parentStyle) {
    if (nodes == null || nodes.isEmpty) return TextSpan();
    return TextSpan(
      children: List.generate(
        nodes.length,
        (index) {
          bool shouldParseHtml = needParseHtml(parentNode);
          final node = nodes[index];
          if (node is m.Text)
            return buildTextSpan(node, parentStyle, shouldParseHtml);
          else if (node is m.Element) {
            if (node.tag == code) return getCodeSpan(node);
            if (node.tag == img) return getImageSpan(node);
            if (node.tag == video) return getVideoSpan(node);
            if (node.tag == a) return getLinkSpan(node);
            if (node.tag == input) return getInputSpan(node);
            if (node.tag == other) return getOtherWidgetSpan(node);
            return getBlockSpan(
              node.children,
              node,
              parentStyle!.merge(getTextStyle(node.tag)),
            );
          }
          return TextSpan();
        },
      ),
    );
  }

  InlineSpan buildTextSpan(
      m.Text node, TextStyle? parentStyle, bool shouldParseHtml) {
    final nodes = shouldParseHtml ? parseHtml(node) : [];
    if (nodes.isEmpty) {
      return TextSpan(text: node.text, style: parentStyle);
    } else {
      return getBlockSpan(nodes as List<m.Node>?, node, parentStyle);
    }
  }
}

///config class for [PWidget]
class PConfig {
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final TextStyle? delStyle;
  final TextStyle? emStyle;
  final TextStyle? strongStyle;
  final TextConfig? textConfig;
  final bool? selectable;
  final OnLinkTap? onLinkTap;
  final LinkGesture? linkGesture;
  final Custom? custom;

  PConfig({
    this.textStyle,
    this.linkStyle,
    this.delStyle,
    this.emStyle,
    this.strongStyle,
    this.textConfig,
    this.onLinkTap,
    this.selectable,
    this.linkGesture,
    this.custom,
  });
}

///config class for [TextStyle]
class TextConfig {
  final TextAlign? textAlign;
  final TextDirection? textDirection;

  TextConfig({this.textAlign, this.textDirection});
}

typedef void OnLinkTap(String? url);
typedef Widget LinkGesture(Widget linkWidget, String? url);
typedef Widget Custom(m.Element element);
