# Project3

## Team Member

Name | UFID
---|---
Aotian Wu | 5139-4302
Keyuan Lu | 2144-2855

## Introduction

In this project, we implement the Tapestry peer-to-peer service deployment infrastructure, which supports dynamic node joining and exiting and provides fault tolerance. We simulate the network nodes with actors in Elixir and assign random locations for each node in order to model the real-world senarios better. A random entrance point (gateway node) is chosen for each new node or new object.


## Investigation

The paper[1] has a clear illustration of the routing, publishing and querying algorithms of **Tapestry**. However, it only gives an outline of the node joining and routing table construction algorithms, which brings us to the paper[2], where psuedo code of node inserting, acknowleged mulitcasting, resource reference transferring and properties hold by each algorithms are given. Our implementation is based on the pseudo code from paper[2].

## How to Run the Program
In the directory of **P2P_Tapestry**  
use command below

```command
mix run project3.exs NodeNumber RequestNumber
```



## Implementation

### Node ID and GUID generation
```elixir
def getHash(key) do
    :crypto.hash(:sha, key) |> Base.encode16
end
```
SHA-1 algorithm is used here to generate IDs in hexadecimal of length 40, which makes them roughly evenly distributed in the name space.

### Initialization

```elixir
def init([]) do
        {:ok, [rt: %{}, bp: %{}, nid: '', max_level: 0, storage: %{}, cache: %{}, return_list: [], pos: {}, root_pid: nil]}   
        # routing table, backpointers, nid, max_level of current routing table, storage, cache. 
    end
```
We make use of the actor model provided by Elixir genServer to simulate the nodes in a Tapestry network. For each node, we maintain the following local state: routing table, backward pointer table, node id, storage of resource references, cache of resource references, simulated location information and some intermediate variables. As a new node joins in, we initialize its routing table to  only store the node itself in each level. And we set the node id as the SHA-1 hashing of its process id.

#### Finding Root Node (Surrogate Node)

```elixir
def next_hop(level, guid)
```
We implement surrogate routing as the paper suggested. The key of the algorithm is a next\_hop function, which can be called successively to forward the message to next node with longer matched prefix. The next\_hop function works by matching one more character of the object id (GUID)'s prefix at a time, if there's no exact match, it will use the next closest character instead. In our implementation, if the next_hop function returns the same node at two consecutive calls, it suggests that the returned node should be a root node of the querying object.

#### Publish and query

```elixir
def publish_object(guid, level, sid, nid)
```
To publish an object, we simply store a resource reference to its root node acquired from multiple next\_hop jumps, and also store the reference to in-between nodes' cache. Since it's a recursive function, a level parameter is required, so that it can recursively check the next level of current node's routing table and match the prefix of object one more character at a time.

```elixir
def query_object(guid, level, nid)
```
To query an object, we also call the next\_hop function until a node finds the object's reference. Along the routing path, if GUID is in the current node's cache, the server id will be returned from cache. Otherwise, forward it to the next hop until it reaches its root node. The reference is guaranteed to be found at the root node as is stated in paper.

#### Insert Node

```elixir
def insert_node(new_nid, nid)
```

The node inserting algorithm is the most challenging one in Tapestry. It requires multicasting new node's entering to other nodes, so that they can add the new node to their routing table. Resource references might also need to be transferred as the new node might become the root node from the next\_node calls of some resources. The algorithm also requires constructing an effective routing table for the new node.


```elixir
def acknowledged_multicast(a, new_nid, func, nid):
```
This function is called in two different places of the inserting algorithms. First, after the new node finds its surrogate node, it first find the common prefix, and then let the surrogate multicasts the new node's routing information to other nodes with the same prefix. The nodes who receive the multicast can then consider adding the new node to its routing table or transfer resource references if necessary. Second, when constructing the routing table for new-coming node, another multicast is required as it requests routing information from reached nodes and uses these nodes as a initial set of neighbors. 


```elixir
def add2table_and_transfer_root(level, new_nid, nid)
```
This function is called during multicasting. It adds the new node to receivers' routing table as well as transfers object pointers that should be rooted at the new node and deletes outdated pointers to maintain correctness.

#### Build Routing Tables
```elixir
def acquire_routing_table(new_nid, root_nid, nid)
```
This function is used to construct a near-optimal routing table for the new node.  A list retrieved from *acknowledged_multicast()* is used as a initial neighbor set. We then use k nearest neighbor algorithm to trim the list to size k (10) and insert these k neighbors to the corresponding level of the routing table. Then we recursively get similar lists for progressively smaller prefixes to fill up the routing table from bottom to top.





## Observations
### What Is Working
We followed the algorithm description from paper[1][2] and implemented **surrogate routing, dynamic node inserting, object publishing and querying**. Our algorithm first constructs the network by inserting nodes **one by one**, followed by performing object publishing and querying. And since the network topology won't change after the construction, we only publish each object once instead of publishing periodically. We can successfully find published objects with about 80% of the time when tested on 1000 nodes.



### Largest Network
Since the multicast process is costly and CPU intensive when simulating the network on a single machine, we can only support 2000 nodes for now, while the number of requests are not limited after the network has been set up.


The largest we have tested:

Number of nodes: 2000  
Number of requests: 100000

### Reference
[1] Zhao B Y, Huang L, Stribling J, et al. Tapestry: A resilient global-scale overlay for service deployment[J]. IEEE Journal on selected areas in communications, 2004, 22(1): 41-53.

[2] Hildrum K, Kubiatowicz J D, Rao S, et al. Distributed object location in a dynamic network[J]. Theory of Computing Systems, 2004, 37(3): 405-440.

