// This code was generated automatically from 'r-original.R'

#include <algorithm>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <numeric>
#include <sstream>
#include <string>
#include <type_traits>
#include <unordered_map>
#include <utility>
#include <vector>

using namespace std;

static inline string trim(const string& s) {
    size_t a = 0, b = s.size();
    while (a < b && isspace(static_cast<unsigned char>(s[a]))) ++a;
    while (b > a && isspace(static_cast<unsigned char>(s[b - 1]))) --b;
    return s.substr(a, b - a);
}

static inline vector<string> split_tabs(const string& s) {
    vector<string> out;
    size_t start = 0;
    while (true) {
        size_t pos = s.find('\t', start);
        if (pos == string::npos) { out.push_back(s.substr(start)); break; }
        out.push_back(s.substr(start, pos - start));
        start = pos + 1;
    }
    return out;
}

static inline vector<string> split_whitespace(const string& s) {
    vector<string> out;
    size_t i = 0, n = s.size();
    while (i < n) {
        while (i < n && isspace(static_cast<unsigned char>(s[i]))) ++i;
        if (i >= n) break;
        size_t j = i;
        while (j < n && !isspace(static_cast<unsigned char>(s[j]))) ++j;
        out.emplace_back(s.substr(i, j - i));
        i = j;
    }
    if (out.empty()) out.emplace_back(string());
    return out;
}

static inline bool looks_tab_separated(const string& header_line) {
    return header_line.find('\t') != string::npos;
}

// -------- C++14-friendly to_num overloads --------
template <typename T>
typename std::enable_if<std::is_floating_point<T>::value, T>::type
to_num(const string& s, T def = T()) {
    string t = trim(s);
    if (t.empty() || t == "NA" || t == "NaN" || t == "nan") {
        return std::numeric_limits<T>::quiet_NaN();
    }
    try {
        return static_cast<T>(stod(t));
    } catch (...) {
        return std::numeric_limits<T>::quiet_NaN();
    }
}

template <typename T>
typename std::enable_if<std::is_integral<T>::value, T>::type
to_num(const string& s, T def = T()) {
    string t = trim(s);
    if (t.empty() || t == "NA" || t == "NaN" || t == "nan") {
        return def;
    }
    try {
        return static_cast<T>(stoll(t));
    } catch (...) {
        return def;
    }
}
// -------------------------------------------------

struct Row {
    // main_rr_contact__area
    double area = std::numeric_limits<double>::quiet_NaN();
    // predicted_probability_to_persist
    double prob = std::numeric_limits<double>::quiet_NaN();
    // main_rr_contact__boundary
    double boundary = std::numeric_limits<double>::quiet_NaN();

    string chain1, chain2, resname1, resname2;
    long long seqnum1 = 0, seqnum2 = 0;

    double area_expected_to_vanish = 0.0;
    double area_expected_to_persist = 0.0;
    double bounded_prob = 0.0;
    double area_badness = 0.0;
    double area_goodness = 0.0;
    double area_pseudoenergy = 0.0;
    double exposure_value = 0.0;
};

struct HeaderMap {
    unordered_map<string, int> idx;
    int at(const string& k) const {
        auto it = idx.find(k);
        return (it == idx.end()) ? -1 : it->second;
    }
};

static bool read_table(const string& path, vector<Row>& rows, string& err) {
    ifstream in(path);
    if (!in) { err = "Cannot open file: " + path; return false; }
    string header_line;
    if (!getline(in, header_line)) { err = "Empty file: " + path; return false; }
    header_line = trim(header_line);

    const bool tabbed = looks_tab_separated(header_line);
    auto split = [&](const string& line) {
        return tabbed ? split_tabs(line) : split_whitespace(line);
    };
    auto header = split(header_line);

    HeaderMap H;
    for (int i = 0; i < (int)header.size(); ++i) H.idx[header[i]] = i;

    const vector<string> required = {
        "main_rr_contact__area",
        "predicted_probability_to_persist",
        "main_rr_contact__boundary",
        "chain1","seqnum1","resname1",
        "chain2","seqnum2","resname2"
    };
    for (size_t i = 0; i < required.size(); ++i) {
        if (H.at(required[i]) < 0) { err = "Missing required column: " + required[i]; return false; }
    }

    string line;
    while (getline(in, line)) {
        if (trim(line).empty()) continue;
        auto cols = split(line);
        if ((int)cols.size() < (int)header.size()) cols.resize(header.size());

        Row r;
        r.area     = to_num<double>(cols[H.at("main_rr_contact__area")]);
        r.prob     = to_num<double>(cols[H.at("predicted_probability_to_persist")], 0.0);
        r.boundary = to_num<double>(cols[H.at("main_rr_contact__boundary")], 0.0);
        r.chain1   = cols[H.at("chain1")];
        r.resname1 = cols[H.at("resname1")];
        r.seqnum1  = to_num<long long>(cols[H.at("seqnum1")], 0);
        r.chain2   = cols[H.at("chain2")];
        r.resname2 = cols[H.at("resname2")];
        r.seqnum2  = to_num<long long>(cols[H.at("seqnum2")], 0);

        // Derived values
        double p = r.prob;

        // Clamp p to [0.005, 0.995]; if NaN, keep NaN so logs become NaN (R-like)
        double bp = p;
        if (!std::isnan(bp)) {
            if (bp < 0.005) bp = 0.005;
            if (bp > 0.995) bp = 0.995;
        }
        r.bounded_prob = bp;

        r.area_expected_to_vanish  = r.area * (1.0 - p);
        r.area_expected_to_persist = r.area * p;

        r.area_badness      = r.area * log(r.bounded_prob);
        r.area_goodness     = r.area * log(1.0 - r.bounded_prob);
        r.area_pseudoenergy = r.area_goodness - r.area_badness;

        // IEEE-754 semantics (Inf/NaN) like R
        r.exposure_value = r.boundary / sqrt(r.area);

        rows.push_back(r);
    }
    return true;
}

struct SuffixCoreResult { double best_core_area_pseudoenergy = 0.0; double best_core_area = 0.0; };

static inline double as_order_key(double x) {
    // Treat NaN as -inf so it sorts last in descending order
    if (std::isnan(x)) return -std::numeric_limits<double>::infinity();
    return x;
}

static SuffixCoreResult best_core_from_rows(const vector<Row>& rows) {
    SuffixCoreResult res; res.best_core_area_pseudoenergy = 0.0; res.best_core_area = 0.0;
    const int N = (int)rows.size();
    if (N == 0) return res;

    vector<int> idx(N);
    iota(idx.begin(), idx.end(), 0);
    sort(idx.begin(), idx.end(), [&](int a, int b){
        double ax = as_order_key(rows[a].exposure_value);
        double bx = as_order_key(rows[b].exposure_value);
        if (ax != bx) return ax > bx; // descending
        // tie-breakers for determinism
        if (rows[a].area_pseudoenergy != rows[b].area_pseudoenergy)
            return rows[a].area_pseudoenergy < rows[b].area_pseudoenergy;
        if (rows[a].area != rows[b].area) return rows[a].area > rows[b].area;
        return a < b;
    });

    vector<double> ord_exposure(N), ord_pseudo(N), ord_area(N);
    int count_pos = 0;
    for (int i = 0; i < N; ++i) {
        const Row& r = rows[idx[i]];
        ord_exposure[i] = r.exposure_value;
        ord_pseudo[i]   = r.area_pseudoenergy;
        ord_area[i]     = r.area;
        if (!std::isnan(r.exposure_value) && r.exposure_value > 0.0) ++count_pos;
    }
    int M = std::max(1, count_pos);

    vector<double> suf_pseudo(N + 1, 0.0), suf_area(N + 1, 0.0);
    for (int i = N - 1; i >= 0; --i) {
        suf_pseudo[i] = suf_pseudo[i + 1] + ord_pseudo[i];
        suf_area[i]   = suf_area[i + 1]   + ord_area[i];
    }

    int best_i = 0;
    double best_pseudo = suf_pseudo[0];
    for (int i = 1; i < M; ++i) {
        if (suf_pseudo[i] < best_pseudo) {
            best_pseudo = suf_pseudo[i];
            best_i = i;
        }
    }
    res.best_core_area_pseudoenergy = suf_pseudo[best_i];
    res.best_core_area              = suf_area[best_i];
    return res;
}

struct ResidueKey {
    string chain; long long seqnum; string resname;
    bool operator==(const ResidueKey& o) const {
        return chain == o.chain && seqnum == o.seqnum && resname == o.resname;
    }
};
struct ResidueKeyHash {
    size_t operator()(const ResidueKey& k) const noexcept {
        size_t h1 = hash<string>{}(k.chain);
        size_t h2 = hash<long long>{}(k.seqnum);
        size_t h3 = hash<string>{}(k.resname);
        return h1 ^ (h2 + 0x9e3779b97f4a7c15ULL + (h1<<6) + (h1>>2)) ^ (h3<<1);
    }
};
struct ResidueAgg {
    double area_pseudoenergy = 0.0;
    double area = 0.0;
    double area_expected_to_persist = 0.0;
    double area_goodness = 0.0;
    double boundary = 0.0;
};

static void write_table_per_residue(const vector<Row>& rows, const string& path) {
    unordered_map<ResidueKey, ResidueAgg, ResidueKeyHash> agg;

    auto add = [&](const string& chain, long long seqnum, const string& resname, const Row& r) {
        if (chain.empty() || resname.empty()) return; // mimic aggregate dropping NA group keys
        ResidueKey key{chain, seqnum, resname};
        ResidueAgg& a = agg[key];
        a.area_pseudoenergy        += r.area_pseudoenergy;
        a.area                     += r.area;
        a.area_expected_to_persist += r.area_expected_to_persist;
        a.area_goodness            += r.area_goodness;
        a.boundary                 += r.boundary;
    };

    for (size_t i = 0; i < rows.size(); ++i) {
        const Row& r = rows[i];
        add(r.chain1, r.seqnum1, r.resname1, r);
        add(r.chain2, r.seqnum2, r.resname2, r);
    }

    struct Rec { ResidueKey k; ResidueAgg a; };
    vector<Rec> out; out.reserve(agg.size());
    for (auto it = agg.begin(); it != agg.end(); ++it) out.push_back({it->first, it->second});
    sort(out.begin(), out.end(), [](const Rec& x, const Rec& y){
        if (x.a.area_pseudoenergy != y.a.area_pseudoenergy)
            return x.a.area_pseudoenergy < y.a.area_pseudoenergy;
        if (x.k.chain != y.k.chain) return x.k.chain < y.k.chain;
        if (x.k.seqnum != y.k.seqnum) return x.k.seqnum < y.k.seqnum;
        return x.k.resname < y.k.resname;
    });

    ofstream f(path);
    f.setf(std::ios::fixed); f << setprecision(15);
    f << "chain\tseqnum\tresname\tarea_pseudoenergy\tarea\tarea_expected_to_persist\tarea_goodness\tboundary\n";
    for (size_t i = 0; i < out.size(); ++i) {
        const auto& r = out[i];
        f << r.k.chain << '\t' << r.k.seqnum << '\t' << r.k.resname << '\t'
          << r.a.area_pseudoenergy << '\t'
          << r.a.area << '\t'
          << r.a.area_expected_to_persist << '\t'
          << r.a.area_goodness << '\t'
          << r.a.boundary << '\n';
    }
}

static void write_table_per_contact(const vector<Row>& rows, const string& path) {
    vector<int> idx(rows.size());
    iota(idx.begin(), idx.end(), 0);
    sort(idx.begin(), idx.end(), [&](int a, int b){
        if (rows[a].area_pseudoenergy != rows[b].area_pseudoenergy)
            return rows[a].area_pseudoenergy < rows[b].area_pseudoenergy;
        if (rows[a].chain1 != rows[b].chain1) return rows[a].chain1 < rows[b].chain1;
        if (rows[a].seqnum1 != rows[b].seqnum1) return rows[a].seqnum1 < rows[b].seqnum1;
        if (rows[a].resname1 != rows[b].resname1) return rows[a].resname1 < rows[b].resname1;
        if (rows[a].chain2 != rows[b].chain2) return rows[a].chain2 < rows[b].chain2;
        if (rows[a].seqnum2 != rows[b].seqnum2) return rows[a].seqnum2 < rows[b].seqnum2;
        return rows[a].resname2 < rows[b].resname2;
    });

    ofstream f(path);
    f.setf(std::ios::fixed); f << setprecision(15);
    f << "chain1\tseqnum1\tresname1\tchain2\tseqnum2\tresname2\tarea_pseudoenergy\tarea\tboundary\tpredicted_probability_to_persist\n";
    for (size_t k = 0; k < idx.size(); ++k) {
        const Row& r = rows[idx[k]];
        f << r.chain1 << '\t' << r.seqnum1 << '\t' << r.resname1 << '\t'
          << r.chain2 << '\t' << r.seqnum2 << '\t' << r.resname2 << '\t'
          << r.area_pseudoenergy << '\t'
          << r.area << '\t'
          << r.boundary << '\t'
          << r.prob << '\n';
    }
}

static void write_summary(const string& path,
                          const string& idvalue,
                          const string& modified,
                          const vector<Row>& rows,
                          const SuffixCoreResult& core_full) {
    double total_area = 0.0, total_area_expected_to_vanish = 0.0,
           total_area_expected_to_persist = 0.0, total_area_pseudoenergy = 0.0,
           total_area_badness = 0.0, total_area_goodness = 0.0;
    for (size_t i = 0; i < rows.size(); ++i) {
        const Row& r = rows[i];
        total_area += r.area;
        total_area_expected_to_vanish  += r.area_expected_to_vanish;
        total_area_expected_to_persist += r.area_expected_to_persist;
        total_area_pseudoenergy        += r.area_pseudoenergy;
        total_area_badness             += r.area_badness;
        total_area_goodness            += r.area_goodness;
    }

    vector<Row> interchain; interchain.reserve(rows.size());
    for (size_t i = 0; i < rows.size(); ++i) if (rows[i].chain1 != rows[i].chain2) interchain.push_back(rows[i]);

    double ic_fraction = 0.0;
    double ic_area_pseudoenergy = 0.0;
    double ic_area_total = 0.0;
    double ic_best_core_pseudoenergy = 0.0;
    double ic_best_core_area = 0.0;

    if (!rows.empty() && interchain.size() == rows.size()) {
        ic_fraction = 1.0;
    } else if (!interchain.empty()) {
        for (size_t i = 0; i < interchain.size(); ++i) {
            ic_area_pseudoenergy += interchain[i].area_pseudoenergy;
            ic_area_total        += interchain[i].area;
        }
        ic_fraction = (total_area > 0.0) ? (ic_area_total / total_area) : 0.0;
        SuffixCoreResult ic_core = best_core_from_rows(interchain);
        ic_best_core_pseudoenergy = ic_core.best_core_area_pseudoenergy;
        ic_best_core_area         = ic_core.best_core_area;
    } else {
        ic_fraction = 0.0;
    }

    ofstream f(path);
    f.setf(std::ios::fixed); f << setprecision(15);
    f << "ID\tmodified\tpseudoenergy\tarea\tbest_core_pseudoenergy\tbest_core_area\tic_fraction";
    if (ic_fraction > 0.0 && ic_fraction < 1.0) {
        f << "\tic_area_pseudoenergy\tic_area_total\tic_best_core_pseudoenergy\tic_best_core_area";
    }
    f << '\n';

    f << idvalue << '\t' << modified << '\t'
      << total_area_pseudoenergy << '\t'
      << total_area << '\t'
      << core_full.best_core_area_pseudoenergy << '\t'
      << core_full.best_core_area << '\t'
      << ic_fraction;

    if (ic_fraction > 0.0 && ic_fraction < 1.0) {
        f << '\t' << ic_area_pseudoenergy
          << '\t' << ic_area_total
          << '\t' << ic_best_core_pseudoenergy
          << '\t' << ic_best_core_area;
    }
    f << '\n';
}

int main(int argc, char** argv) {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    if (argc < 3) {
        cerr << "Usage: " << argv[0] << " <ID> <modified>\n";
        return 1;
    }
    const string idvalue  = argv[1];
    const string modified = argv[2];

    vector<Row> rows;
    string err;
    if (!read_table("table", rows, err)) {
        cerr << "Error: " << err << "\n";
        return 2;
    }

    SuffixCoreResult core_full = best_core_from_rows(rows);
    write_table_per_residue(rows, "table_per_residue");
    write_table_per_contact(rows, "table_per_contact");
    write_summary("summary", idvalue, modified, rows, core_full);
    return 0;
}
