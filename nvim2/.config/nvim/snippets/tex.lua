local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {

    s("beg", fmt(
        [[
        \begin{{{}}}
            {}
        \end{{{}}}
        ]], {
            i(1), i(0), rep(1)
        }
    )),

    s("frac", fmt(
        [[
        \frac{{{}}}{{{}}}
        ]], {
            i(1), i(2)
        }
    )),

    s("template", fmt(
        [[
        \documentclass[12pt]{{article}}

        \usepackage[margin=1in]{{geometry}}

        \title{{{}}}
        \author{{Jacky Lin}}
        \date{{\today}}

        \begin{{document}}

        \maketitle

        \section{{{}}}

        \end{{document}}

        \end{{article}}
        ]], {
            i(1), i(2)
        }
    )),

    s("sec", fmt(
        [[
        \section{{{}}}
        ]], {
            i(1)
        }
    )),

    s("math", fmt(
        [[
        \begin{{math}}
            {}
        \end{{math}}
        ]], {
            i(0)
        }
    )),

    s("doc", fmt(
        [[
        \begin{{document}}
            {}
        \end{{document}}
        ]], {
            i(0)
        }
    )),

    s("2matrix", fmt(
        [[
        \begin{{bmatrix}}
            {} & {} \\
            {} & {}
        \end{{bmatrix}}
        ]], {
            i(1), i(2),
            i(3), i(4),
        }
    )),

    s("3matrix", fmt(
        [[
        \begin{{bmatrix}}
            {} & {} & {} \\
            {} & {} & {} \\
            {} & {} & {}
        \end{{bmatrix}}
        ]], {
            i(1), i(2), i(3),
            i(4), i(5), i(6),
            i(7), i(8), i(9),
        }
    )),

    s("item", fmt(
        [[
        \begin{{itemize}}
            \item {}
        \end{{itemize}}
        ]], {
            i(1)
        }
    )),

    s("import math", {
        t("\\usepackage{amsmath}"),
    }),

    s("import image", {
        t("\\usepackage{graphicx}"),
    }),

    s("import links", {
        t("\\usepackage{hyperref}"),
    }),

    s("import enumitem", {
        t("\\usepackage{enumitem}"),
    }),

    s("P union", fmt(
        [[
        P({} \cup {})
        ]], {
            i(1), i(2)
        }
    )),

    s("P intersection", fmt(
        [[
        P({} \cap {})
        ]], {
            i(1), i(2)
        }
    )),

    s("alph", fmt(
        [[
        \begin{{enumerate}}[label=\alph*.)]
            \item {}
        \end{{enumerate}}
        ]], {
            i(0)
        }
    )),

    s("roman", fmt(
        [[
        \begin{{enumerate}}[label=\roman*.)]
            \item {}
        \end{{enumerate}}
        ]], {
            i(0)
        }
    )),

    s("P conditional", fmt(
        [[
        P({} \mid {})
        ]], {
            i(1), i(2)
        }
    )),

    s("addtocounter", fmt(
        [[
        \addtocounter{{enumi}}{{{}}}
        ]], {
            i(0)
        }
    )),

    s("combination", fmt(
        [[
        \binom{{{}}}{{{}}}
        ]], {
            i(1), i(2)
        }
    )),

    s("int", fmt(
        [[
        \int_{{{}}}^{{{}}}
        ]], {
            i(1), i(2)
        }
    )),

    s("sum", fmt(
        [[
        \sum_{{{}}}^{{{}}}
        ]], {
            i(1), i(2)
        }
    )),

}
