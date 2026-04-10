// GENERATED FILE — DO NOT EDIT.
// Source: src/rules/rules.json
// Regenerate: dart run tool/build.dart

const rulesJson = r'''
{
  "version": "1.0.0",
  "rules": [
    {
      "id": "visual/hardcoded-color",
      "category": "visual",
      "severity": "warning",
      "title": "Hardcoded Color constant",
      "description": "Use ColorScheme semantic tokens instead of Colors.purple or Color(0xFF...).",
      "rationale": "Hardcoded colors bypass theme, break dark mode, and block rebranding.",
      "detect": {
        "type": "ast",
        "pattern": "PropertyAccess(target='Colors', name=NOT_IN['transparent'])",
        "alt_pattern": "InstanceCreationExpression(type='Color', const=true)"
      },
      "fix_hint": "Replace with Theme.of(context).colorScheme.primary (or appropriate semantic token).",
      "references": ["color.md#semantic-tokens"],
      "examples": {
        "bad": "Container(color: Colors.purple)",
        "good": "Container(color: Theme.of(context).colorScheme.primary)"
      }
    },
    {
      "id": "visual/roboto-default",
      "category": "visual",
      "severity": "info",
      "title": "Roboto default font",
      "description": "Relying on platform default Roboto signals default AI output. Use google_fonts or a bundled custom font.",
      "rationale": "Default Roboto is the most common AI-generated Flutter font choice. A distinct type pairing is the fastest way to escape generic aesthetics.",
      "detect": {
        "type": "regex",
        "pattern": "ThemeData\\s*\\(\\s*\\)(?![^)]*textTheme)"
      },
      "fix_hint": "Use GoogleFonts.interTextTheme() or load a bundled font via pubspec assets.",
      "references": ["typography.md#choosing-fonts"],
      "examples": {
        "bad": "ThemeData()",
        "good": "ThemeData(textTheme: GoogleFonts.manropeTextTheme())"
      }
    },
    {
      "id": "visual/gradient-abuse",
      "category": "visual",
      "severity": "info",
      "title": "Purple gradient background",
      "description": "Purple/pink LinearGradient on Scaffold or hero is an AI-slop tell.",
      "rationale": "LLMs default to purple gradients for 'premium' feel. Use a subtle single color or brand-derived seed.",
      "detect": {
        "type": "ast",
        "pattern": "LinearGradient(colors contains PURPLE_FAMILY)"
      },
      "fix_hint": "Replace with ColorScheme.surfaceTint or a brand-derived seed color.",
      "references": ["color.md#gradients"],
      "examples": {
        "bad": "LinearGradient(colors: [Colors.purple, Colors.pink])",
        "good": "Container(color: colorScheme.surface)"
      }
    },
    {
      "id": "visual/pure-black-text",
      "category": "visual",
      "severity": "warning",
      "title": "Pure black text color",
      "description": "Colors.black has too much contrast against white surfaces and fails in dark mode.",
      "rationale": "Material 3 uses onSurface which resolves to a tuned near-black/near-white per brightness.",
      "detect": {
        "type": "ast",
        "pattern": "TextStyle(color=Colors.black)"
      },
      "fix_hint": "Use Theme.of(context).colorScheme.onSurface.",
      "references": ["color.md#text-colors"],
      "examples": {
        "bad": "Text('Hello', style: TextStyle(color: Colors.black))",
        "good": "Text('Hello', style: Theme.of(context).textTheme.bodyLarge)"
      }
    },
    {
      "id": "visual/nested-cards",
      "category": "visual",
      "severity": "warning",
      "title": "Card nested inside Card",
      "description": "Nested Card widgets double-up elevation and create visual noise.",
      "rationale": "Each Card adds shadow and rounded corners. Nesting amplifies both. Use a single Card with internal structure instead.",
      "detect": {
        "type": "ast",
        "pattern": "Card(child DESCENDANT Card)"
      },
      "fix_hint": "Collapse to a single Card; use Divider or ListTile sections for internal structure.",
      "references": ["spacing.md#card-hierarchy"],
      "examples": {
        "bad": "Card(child: Card(child: Text('x')))",
        "good": "Card(child: ListTile(title: Text('x')))"
      }
    },
    {
      "id": "visual/shadow-overuse",
      "category": "visual",
      "severity": "info",
      "title": "Excessive elevation",
      "description": "Elevation > 8 on a non-floating surface creates cartoonish shadows.",
      "rationale": "Material 3 uses tonal elevation (surfaceTint) more than shadow. High elevation values are a holdover from Material 2.",
      "detect": {
        "type": "ast",
        "pattern": "Card(elevation > 8) OR Material(elevation > 8)"
      },
      "fix_hint": "Use elevation 0-4 with surfaceTintColor, or rely on Material 3 default tonal elevation.",
      "references": ["spacing.md#elevation"],
      "examples": {
        "bad": "Card(elevation: 16, child: ...)",
        "good": "Card(elevation: 1, child: ...)"
      }
    },
    {
      "id": "visual/inline-textstyle",
      "category": "visual",
      "severity": "warning",
      "title": "Inline TextStyle instead of theme",
      "description": "Writing TextStyle(fontSize: 18, fontWeight: ...) inline bypasses the type scale.",
      "rationale": "Theme-driven typography guarantees consistency and dark-mode safety. Inline styles fragment the scale.",
      "detect": {
        "type": "ast",
        "pattern": "TextStyle(fontSize=LITERAL)"
      },
      "fix_hint": "Use Theme.of(context).textTheme.bodyLarge (etc.) and .copyWith() for deltas.",
      "references": ["typography.md#type-scale"],
      "examples": {
        "bad": "Text('Hi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))",
        "good": "Text('Hi', style: Theme.of(context).textTheme.titleMedium)"
      }
    },
    {
      "id": "layout/missing-safearea",
      "category": "layout",
      "severity": "error",
      "title": "Scaffold body without SafeArea",
      "description": "Scaffold body content collides with status bar, notch, and gesture insets without SafeArea.",
      "rationale": "SafeArea applies MediaQuery.padding to children; without it, content renders under system UI on modern devices.",
      "detect": {
        "type": "ast",
        "pattern": "Scaffold(body=NOT_DESCENDANT_OF(SafeArea) AND appBar==null)"
      },
      "fix_hint": "Wrap body in SafeArea(child: ...), or use Scaffold(appBar: ...) which handles the top inset.",
      "references": ["spacing.md#safe-areas"],
      "examples": {
        "bad": "Scaffold(body: Column(children: [...]))",
        "good": "Scaffold(body: SafeArea(child: Column(children: [...])))"
      }
    },
    {
      "id": "layout/nested-padding",
      "category": "layout",
      "severity": "warning",
      "title": "Padding inside Container with padding",
      "description": "Container has its own padding; wrapping it in Padding duplicates the concept.",
      "rationale": "Decoration-free Container wrapping a Padding wrapping a child is three widgets where one suffices.",
      "detect": {
        "type": "ast",
        "pattern": "Padding(child=Container(padding!=null)) OR Container(child=Padding)"
      },
      "fix_hint": "Use a single Container(padding: ...) or a single Padding(padding: ...).",
      "references": ["spacing.md#widget-economy"],
      "examples": {
        "bad": "Padding(padding: ..., child: Container(padding: ..., child: Text('x')))",
        "good": "Container(padding: EdgeInsets.all(16), child: Text('x'))"
      }
    },
    {
      "id": "layout/magic-numbers",
      "category": "layout",
      "severity": "info",
      "title": "Non-grid padding/margin values",
      "description": "EdgeInsets values not aligned to 4/8pt grid (e.g. 17, 23, 11) are an AI tell and break visual rhythm.",
      "rationale": "The 4pt grid is the de-facto Material standard. Odd values look designed by committee.",
      "detect": {
        "type": "ast",
        "pattern": "EdgeInsets(any value NOT IN {0,2,4,6,8,12,16,20,24,32,40,48,56,64})"
      },
      "fix_hint": "Round to the nearest 4/8 multiple, or extract to named const tokens (kSpaceSm = 8, kSpaceMd = 16).",
      "references": ["spacing.md#grid-values"],
      "examples": {
        "bad": "EdgeInsets.all(17)",
        "good": "EdgeInsets.all(16)"
      }
    },
    {
      "id": "layout/hardcoded-width",
      "category": "layout",
      "severity": "warning",
      "title": "Fixed Container width in mobile layout",
      "description": "Hardcoded widths (e.g. width: 300) break on small phones and foldables.",
      "rationale": "Mobile must work from 320dp (small phones) to 900dp+ (foldables unfolded). Fixed pixel widths assume a median device.",
      "detect": {
        "type": "ast",
        "pattern": "Container(width=LITERAL where LITERAL > 120)"
      },
      "fix_hint": "Use Expanded, Flexible, or FractionallySizedBox. For images, use AspectRatio.",
      "references": ["responsive.md#fluid-widths"],
      "examples": {
        "bad": "Container(width: 300, child: Text('long...'))",
        "good": "Expanded(child: Text('long...'))"
      }
    },
    {
      "id": "layout/no-flexible",
      "category": "layout",
      "severity": "warning",
      "title": "Row/Column children with implicit sizing",
      "description": "Row or Column with long Text children but no Flexible/Expanded will overflow.",
      "rationale": "RenderFlex overflow is the #1 Flutter layout bug in AI-generated code.",
      "detect": {
        "type": "ast",
        "pattern": "Row(children contains Text without Flexible ancestor)"
      },
      "fix_hint": "Wrap variable-length children in Flexible or Expanded.",
      "references": ["responsive.md#flex-children"],
      "examples": {
        "bad": "Row(children: [Icon(Icons.person), Text('Very long name...')])",
        "good": "Row(children: [Icon(Icons.person), Flexible(child: Text('Very long name...'))])"
      }
    },
    {
      "id": "layout/fixed-row-overflow",
      "category": "layout",
      "severity": "error",
      "title": "Row/Column explicit width/height exceeds parent",
      "description": "SizedBox(width: double.infinity) inside a Row causes immediate overflow.",
      "rationale": "Infinite width constraints propagate up and produce cryptic 'RenderBox was not laid out' errors.",
      "detect": {
        "type": "ast",
        "pattern": "Row(children contains SizedBox(width=double.infinity))"
      },
      "fix_hint": "Use Expanded instead of infinite SizedBox inside flex widgets.",
      "references": ["responsive.md#constraint-propagation"],
      "examples": {
        "bad": "Row(children: [SizedBox(width: double.infinity, child: Text('x'))])",
        "good": "Row(children: [Expanded(child: Text('x'))])"
      }
    },
    {
      "id": "platform/material-on-ios",
      "category": "platform",
      "severity": "info",
      "title": "Material widget on iOS-only path",
      "description": "A MaterialButton or ElevatedButton inside a Platform.isIOS branch is a platform mismatch.",
      "rationale": "iOS users expect Cupertino affordances. Material on iOS paths is a tell of unconsidered adaptation.",
      "detect": {
        "type": "ast",
        "pattern": "IfStatement(condition=Platform.isIOS, body contains MaterialWidget)"
      },
      "fix_hint": "Use the Cupertino equivalent (CupertinoButton) or an adaptive wrapper.",
      "references": ["interaction.md#platform-adaptation"],
      "examples": {
        "bad": "if (Platform.isIOS) ElevatedButton(...)",
        "good": "if (Platform.isIOS) CupertinoButton(...)"
      }
    },
    {
      "id": "platform/cupertino-on-android",
      "category": "platform",
      "severity": "info",
      "title": "Cupertino widget on Android-only path",
      "description": "Mirror of material-on-ios: CupertinoButton inside Platform.isAndroid.",
      "rationale": "Android users expect Material Design affordances.",
      "detect": {
        "type": "ast",
        "pattern": "IfStatement(condition=Platform.isAndroid, body contains CupertinoWidget)"
      },
      "fix_hint": "Use the Material equivalent (ElevatedButton) or an adaptive wrapper.",
      "references": ["interaction.md#platform-adaptation"],
      "examples": {
        "bad": "if (Platform.isAndroid) CupertinoButton(...)",
        "good": "if (Platform.isAndroid) FilledButton(...)"
      }
    },
    {
      "id": "platform/wrong-nav-pattern",
      "category": "platform",
      "severity": "info",
      "title": "BottomNavigationBar on iOS without Cupertino variant",
      "description": "Using Material BottomNavigationBar on iOS skips Cupertino's native tab bar feel.",
      "rationale": "Platform-idiomatic navigation reduces user friction and signals attention to detail.",
      "detect": {
        "type": "ast",
        "pattern": "BottomNavigationBar in project without CupertinoTabBar branch"
      },
      "fix_hint": "Use PlatformTabScaffold from package:flutter_platform_widgets or branch on Platform.isIOS.",
      "references": ["interaction.md#navigation-patterns"],
      "examples": {
        "bad": "Scaffold(bottomNavigationBar: BottomNavigationBar(...))",
        "good": "Platform.isIOS ? CupertinoTabScaffold(...) : Scaffold(bottomNavigationBar: ...)"
      }
    },
    {
      "id": "platform/missing-adaptive",
      "category": "platform",
      "severity": "info",
      "title": "Switch without Switch.adaptive",
      "description": "Switch renders as Material on both platforms; Switch.adaptive uses CupertinoSwitch on iOS.",
      "rationale": "Flutter provides .adaptive constructors specifically for this — use them.",
      "detect": {
        "type": "ast",
        "pattern": "InstanceCreationExpression(type='Switch', constructor!='adaptive')"
      },
      "fix_hint": "Use Switch.adaptive(value: ..., onChanged: ...).",
      "references": ["interaction.md#adaptive-controls"],
      "examples": {
        "bad": "Switch(value: on, onChanged: f)",
        "good": "Switch.adaptive(value: on, onChanged: f)"
      }
    },
    {
      "id": "code-quality/missing-const",
      "category": "code-quality",
      "severity": "info",
      "title": "Missing const constructor",
      "description": "Widgets that can be const should be const — affects rebuild performance.",
      "rationale": "Const widgets are identity-stable and skip rebuild. This is the single biggest Flutter perf win.",
      "detect": {
        "type": "lint-reuse",
        "rule": "prefer_const_constructors"
      },
      "fix_hint": "Prefix with const where all args are const.",
      "references": ["interaction.md#performance"],
      "examples": {
        "bad": "Text('Hello')",
        "good": "const Text('Hello')"
      }
    },
    {
      "id": "code-quality/missing-semantics",
      "category": "code-quality",
      "severity": "warning",
      "title": "Icon-only button missing semantic label",
      "description": "IconButton without tooltip or semanticLabel is inaccessible to screen readers.",
      "rationale": "Accessibility is not optional. TalkBack/VoiceOver users need verbal labels on icon-only controls.",
      "detect": {
        "type": "ast",
        "pattern": "IconButton(tooltip==null) OR Icon(semanticLabel==null WHERE in GestureDetector)"
      },
      "fix_hint": "Add tooltip: 'Action name' to IconButton, or wrap in Semantics(label: ...).",
      "references": ["ux-writing.md#a11y-labels"],
      "examples": {
        "bad": "IconButton(icon: Icon(Icons.close), onPressed: f)",
        "good": "IconButton(icon: Icon(Icons.close), tooltip: 'Close', onPressed: f)"
      }
    },
    {
      "id": "code-quality/missing-dispose",
      "category": "code-quality",
      "severity": "error",
      "title": "Controller created in State without dispose",
      "description": "AnimationController, TextEditingController, ScrollController etc. must be disposed.",
      "rationale": "Undisposed controllers leak memory and fire callbacks after widget unmount.",
      "detect": {
        "type": "ast",
        "pattern": "State with Controller field AND no dispose() method"
      },
      "fix_hint": "Override dispose(), call controller.dispose(), then super.dispose().",
      "references": ["motion.md#lifecycle"],
      "examples": {
        "bad": "class _S extends State { final c = AnimationController(...); }",
        "good": "class _S extends State { final c = ...; @override void dispose() { c.dispose(); super.dispose(); } }"
      }
    },
    {
      "id": "code-quality/hardcoded-strings",
      "category": "code-quality",
      "severity": "info",
      "title": "Hardcoded user-facing string",
      "description": "Text('Welcome') is untranslatable; use AppLocalizations.of(context).welcome.",
      "rationale": "Apps that ship without i18n scaffolding have to rewrite every Text widget later. Start correct.",
      "detect": {
        "type": "ast",
        "pattern": "Text(LITERAL_STRING) WHERE literal is not empty and not debug"
      },
      "fix_hint": "Extract to ARB file and use AppLocalizations.of(context).<key>.",
      "references": ["ux-writing.md#localization"],
      "examples": {
        "bad": "Text('Welcome')",
        "good": "Text(AppLocalizations.of(context)!.welcome)"
      }
    },
    {
      "id": "code-quality/setstate-after-async",
      "category": "code-quality",
      "severity": "error",
      "title": "setState after async gap without mounted check",
      "description": "Calling setState after an await without checking mounted throws if the widget was disposed.",
      "rationale": "This is the most common crash in Flutter async code. Always guard.",
      "detect": {
        "type": "lint-reuse",
        "rule": "use_build_context_synchronously"
      },
      "fix_hint": "Guard with `if (!mounted) return;` before setState.",
      "references": ["interaction.md#async-safety"],
      "examples": {
        "bad": "await fetch(); setState(() => data = result);",
        "good": "await fetch(); if (!mounted) return; setState(() => data = result);"
      }
    },
    {
      "id": "code-quality/missing-key",
      "category": "code-quality",
      "severity": "info",
      "title": "Widget in list without Key",
      "description": "Widgets inside a list without stable keys cause incorrect state preservation on reorder.",
      "rationale": "Flutter uses position-based matching by default; keys fix identity-based matching.",
      "detect": {
        "type": "ast",
        "pattern": "ListView children OR Column children with StatefulWidget and no key"
      },
      "fix_hint": "Pass key: ValueKey(uniqueId) to list children.",
      "references": ["interaction.md#list-keys"],
      "examples": {
        "bad": "items.map((i) => TodoTile(i)).toList()",
        "good": "items.map((i) => TodoTile(key: ValueKey(i.id), i)).toList()"
      }
    },
    {
      "id": "code-quality/swallowed-errors",
      "category": "code-quality",
      "severity": "warning",
      "title": "Empty catch block",
      "description": "try { ... } catch (_) {} hides bugs and makes debugging impossible.",
      "rationale": "Errors should be logged, surfaced to the user, or rethrown — never silently swallowed.",
      "detect": {
        "type": "ast",
        "pattern": "CatchClause(body is empty Block)"
      },
      "fix_hint": "At minimum: debugPrint('$e'); Better: show SnackBar or log to crash reporter.",
      "references": ["interaction.md#error-handling"],
      "examples": {
        "bad": "try { api.call(); } catch (_) {}",
        "good": "try { api.call(); } catch (e, st) { debugPrint('$e'); reportError(e, st); }"
      }
    }
  ]
}
''';
