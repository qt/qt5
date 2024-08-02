#Copyright (C) 2024 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

import re

import axivion.config
from axivion.analysis.post_processing import FilterAction
from bauhaus import ir

analysis = axivion.config.get_analysis()

qt_inline_pattern = re.compile(r"QT_.*_INLINE(_IMPL)?_SINCE\(\d+,\d+\)")
def exclude_inlined_by_qt_inline_macro(sv, ir_graph):
    node = ir_graph.get_node(ir.Physical, sv.primary_sloc.pir_node_number)

    # we have to check on the token stream as the macro might expand to nothing
    # -> only the invocation is in the IR, but not in the AST of the routine decl / def
    preceeding_string = ""

    token = node.Token
    while True:
        try:
            token_value = re.sub('^#\\s+', '#', token.Value)
            if token_value in {';', '{', '}', '#define'}:
                break
            preceeding_string = token.Value + preceeding_string
            token = token.prev()
        except StopIteration:
            break
    if re.match(qt_inline_pattern, preceeding_string):
        return FilterAction.exclude
    return FilterAction.normal

analysis['Qt-Generic-NoFunctionDefinitionInHeader'].post_processing.add_filter(exclude_inlined_by_qt_inline_macro, inputs=[ir.Graph])
