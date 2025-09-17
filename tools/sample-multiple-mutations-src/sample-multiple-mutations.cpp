#include <iostream>
#include <algorithm>
#include <random>
#include <string>
#include <sstream>
#include <limits>
#include <set>
#include <stdexcept>

namespace
{

struct SingleMutation
{
	std::string position_id;
	std::string residue_name;
	double goodness;

	SingleMutation() : goodness(0.0)
	{
	}
};

struct Racer
{
	double t;
	std::size_t index;

	Racer() : t(std::numeric_limits<double>::max()), index(0)
	{
	}

    bool operator<(const Racer& r) const
    {
        return ((t<r.t) || (t==r.t && index<r.index));
    }
};

std::vector<std::size_t> sample_multiple_mutations(std::mt19937_64& rng, const std::vector<SingleMutation>& reference_single_mutations, const int number_of_mutations)
{
	static std::uniform_real_distribution<double> urd(0.0, 1.0);
	static std::vector<Racer> racers;
	racers.resize(reference_single_mutations.size());
	for(std::size_t i=0;i<racers.size();i++)
	{
		const double e=std::max(urd(rng), std::numeric_limits<double>::min());
		racers[i].index=i;
		racers[i].t=0.0-(std::log(e)/reference_single_mutations[i].goodness);
	}
	std::sort(racers.begin(), racers.end());
	std::vector<std::size_t> result;
	result.reserve(number_of_mutations);
	std::set<std::string> used_position_ids;
	for(std::size_t i=0;i<racers.size() && static_cast<int>(result.size())<number_of_mutations;i++)
	{
		const std::size_t smi=racers[i].index;
		const SingleMutation& sm=reference_single_mutations[smi];
		if(used_position_ids.count(sm.position_id)==0)
		{
			result.push_back(smi);
			used_position_ids.insert(sm.position_id);
		}
	}
	std::sort(result.begin(), result.end());
	return result;
}

}

int main(const int argc, const char** argv)
{
	try
	{
		if(argc!=5)
		{
			throw std::runtime_error(std::string("Not exactly 4 command line arguments, must be 'seed lambda maximum_mutations number_of_results'"));
		}

		std::ostringstream args_output;
		for(int i=1;i<argc;i++)
		{
			args_output << argv[i] << " ";
		}

		int seed=42;
		double lambda=1.0;
		int maximum_mutations=8;
		int number_of_results=1000;

		{
			std::istringstream args_input(args_output.str());

			args_input >> seed;
			if(args_input.fail())
			{
				throw std::runtime_error(std::string("Failed to read command line argument for 'seed'"));
			}

			args_input >> lambda;
			if(args_input.fail())
			{
				throw std::runtime_error(std::string("Failed to read command line argument for 'lambda'"));
			}

			args_input >> maximum_mutations;
			if(args_input.fail())
			{
				throw std::runtime_error(std::string("Failed to read command line argument for 'maximum_mutations'"));
			}

			args_input >> number_of_results;
			if(args_input.fail())
			{
				throw std::runtime_error(std::string("Failed to read command line argument for 'number_of_results'"));
			}
		}

		if(seed<0)
		{
			throw std::runtime_error(std::string("Invalid value of 'seed', must be positive"));
		}

		if(lambda<0.0)
		{
			throw std::runtime_error(std::string("Invalid value of 'lambda', must be positive"));
		}

		if(maximum_mutations<2)
		{
			throw std::runtime_error(std::string("Invalid value of 'maximum_mutations', must be >=2"));
		}

		if(number_of_results<1)
		{
			throw std::runtime_error(std::string("Invalid value of 'number_of_results', must be >=1"));
		}

		std::vector<SingleMutation> reference_single_mutations;

		while(std::cin.good())
		{
			std::string line;
			std::getline(std::cin, line);
			if(!line.empty())
			{
				std::istringstream linput(line);
				SingleMutation sm;

				linput >> sm.position_id;
				if(linput.fail())
				{
					throw std::runtime_error(std::string("Failed to read position ID from line '")+line+"'");
				}

				linput >> sm.residue_name;
				if(linput.fail())
				{
					throw std::runtime_error(std::string("Failed to read residue name from line '")+line+"'");
				}

				linput >> sm.goodness;
				if(linput.fail())
				{
					throw std::runtime_error(std::string("Failed to read goodness value from line '")+line+"'");
				}

				if(sm.goodness>0.0)
				{
					reference_single_mutations.push_back(sm);
				}
			}
		}

		std::mt19937_64 rng(seed);
		std::poisson_distribution<int> p_distribution(lambda);

		for(int i=0;i<number_of_results;i++)
		{
			const int sampled_number_of_mutations=std::min(p_distribution(rng)+2, maximum_mutations);
			const std::vector<std::size_t> ids=sample_multiple_mutations(rng, reference_single_mutations, sampled_number_of_mutations);
			for(std::size_t j=0;j<ids.size();j++)
			{
				const SingleMutation& sm=reference_single_mutations[ids[j]];
				std::cout << sm.position_id << " " << sm.residue_name << ((j+1)<ids.size() ? " " : "\n");
			}
		}
	}
	catch(const std::exception& e)
	{
		std::cerr << "Exception caught: " << e.what() << std::endl;
	}
	catch(...)
	{
		std::cerr << "Unknown exception caught." << std::endl;
	}

	return 0;
}

